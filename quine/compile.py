SRC = './src (DO NOT RUN).pde'
DEST = './build/quine/quine.pde'

def main():
    print('Please wait...')
    with open(DEST, 'w') as fout:
        def p(*a, **kw):
            print(*a, file = fout, **kw)
            print(*a, **kw)
        
        with open(SRC, 'r') as fin:
            lines = [*fin]
            fout.writelines(lines)
            len_GOD = len(lines)
        p('  GOD = new char[', len_GOD, '][];', sep = '')
        with open(SRC, 'r') as f:
            for i, line in enumerate(f):
                line = line[:-1]
                if (i % 100 == 0) :
                    newGOD = f"initGod{i // 100}()"
                    p("  " + newGOD + ";")
                    p("}")
                    p("void", newGOD, "{")
                p('  GOD[', i, '] = new char[] {', end = '', sep = '')
                for char in line:
                    p(ord(char), ', ', end = '', sep = '')
                p('};')
        assert i == len_GOD - 1
        p('}')

main()
