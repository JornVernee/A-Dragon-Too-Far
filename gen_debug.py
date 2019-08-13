import io,sys,re

class extractor:
    def __init__(self, pattern, func):
        self._pattern = pattern
        self._func = func

    def try_extract(self, line):
        matcher = re.search(self._pattern, line)
        if matcher:
            return self._func(matcher)
        else:
            return []

class comp_extractor:
    def __init__(self, *args):
        self._extractors = args

    def extract(self, line):
        for e in self._extractors:
            res = e.try_extract(line)
            if res != []:
                return res
        return []

def get_funcs(path_in):
    res = []
    with open(path_in) as f:
        in_text = False
        for line in f:
            if line == ".text\n":
                in_text = True
            if line == ".data\n":
                in_text = False
            if in_text:
                matcher = re.match(r"(\w+):", line)
                if matcher:
                    res.append(matcher.group(1))
    return res

def ev_ext(matcher):
    return [matcher.group(1)]

def make_ext(matcher):
    tpl = list(map(str.strip, matcher.group(1).split(",")))
    return ["ev_" + tpl[0]]

def get_events(path_in):
    names = ["msg", "yesno_event", "special_event", "1op_std_event", "std_event", "non-std_event", "pseudo"]
    ext = comp_extractor(extractor(r"(ev_\w+):", ev_ext), extractor(r"make_(?:" + "|".join(names) + ") ([^\n]+)", make_ext))
    res = []
    with open(path_in) as file:
        in_data = False
        for line in file:
            res.extend(ext.extract(line))

    return res

def make_op_ext(matcher):
    tpl = list(map(str.strip, matcher.group(1).split(",")))
    return ["ev_" + tpl[0] + "_op_" + tpl[1]]

def yesno_ext(matcher):
    tpl = list(map(str.strip, matcher.group(1).split(",")))
    return ["ev_" + tpl[0] + "_op_yes", "ev_" + tpl[0] + "_op_no"]

def op_ext(matcher):
    tpl = list(map(str.strip, matcher.group(1).split(",")))
    return ["ev_" + tpl[0] + "_op_1"]

def get_ops(path_in):
    ext = comp_extractor(
        extractor(r"make_op ([^\n]+)", make_op_ext),
        extractor(r"make_yesno_event ([^\n]+)", yesno_ext),
        extractor(r"make_1op_std_event ([^\n]+)", op_ext)
        )
    res = []
    with open(path_in) as file:
        in_data = False
        for line in file:
            res.extend(ext.extract(line))

    return res

def name_lbl(func_name):
    return "n_" + func_name

def write_table_entry(file, name):
    file.writelines([name_lbl(name) + ": .string \"" + name + "\"\n"])

def table_line(func_name, length_name=0):
    res = "\t.long "
    
    name = name_lbl(func_name)
    name += (" " * (max(length_name - len(name), 0) + 1))
    res += name

    res += "," + func_name
    res += "\n"
    return res

def longest(mapper, strings):
    max_l = 0
    for s in strings:
        tmp = mapper(s)
        max_l = max(max_l, len(tmp))

    return max_l

def write_table(file, name, elements):
    table_name = name + "_table"
    file.writelines([table_name, ":\n"])
    m_name_l = longest(name_lbl, elements)
    
    for e in elements:
        file.writelines([table_line(e, m_name_l)])
    file.writelines([table_name, "_size: .long (((. - ", table_name, ") / 4) / 2)\n\n"])

    for e in elements:
        write_table_entry(file, e)
    file.writelines(["\n"])

if __name__ == "__main__":
    path_in = "ADTF_Revive.s"
    path_ev_op = "ADTF_Ev_Op.s"
    path_out = "ADTF_Debug_gen.s"
 
    with open(path_out, mode='w') as file:
        file.writelines([".file \"ADTF_Debug_gen.s\"", "\n", ".data", "\n"])
        
        write_table(file, "function", get_funcs(path_in))
        write_table(file, "event", get_events(path_ev_op))
        write_table(file, "option", get_ops(path_ev_op))

    
    


    
