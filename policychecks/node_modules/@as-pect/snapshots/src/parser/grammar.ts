// Generated automatically by nearley, version 2.20.1
// http://github.com/Hardmath123/nearley
// Bypasses TS6133. Allow declared but unused functions.
// @ts-ignore
function id(d: any[]): any { return d[0]; }

interface NearleyToken {
  value: any;
  [key: string]: any;
};

interface NearleyLexer {
  reset: (chunk: string, info: any) => void;
  next: () => NearleyToken | undefined;
  save: () => any;
  formatError: (token: never) => string;
  has: (tokenType: string) => boolean;
};

interface NearleyRule {
  name: string;
  symbols: NearleySymbol[];
  postprocess?: (d: any[], loc?: number, reject?: {}) => any;
};

type NearleySymbol = string | { literal: any } | { test: (token: any) => boolean };

interface Grammar {
  Lexer: NearleyLexer | undefined;
  ParserRules: NearleyRule[];
  ParserStart: string;
};

const grammar: Grammar = {
  Lexer: undefined,
  ParserRules: [
    {"name": "start$ebnf$1$subexpression$1", "symbols": ["lines", "_"]},
    {"name": "start$ebnf$1", "symbols": ["start$ebnf$1$subexpression$1"], "postprocess": id},
    {"name": "start$ebnf$1", "symbols": [], "postprocess": () => null},
    {"name": "start", "symbols": ["_", "start$ebnf$1"], "postprocess":  d => {
          const results = d[1];
          const map = new Map<string, string>();
          if (results) {
            for (let i = 0; i < results[0].length; i++) {
              const [key, value] = results[0][i];
              if (map.has(key)) throw new Error("Invalid snapshot.");
              map.set(key, value);
            }
          }
          return map;
        } },
    {"name": "lines$ebnf$1", "symbols": []},
    {"name": "lines$ebnf$1$subexpression$1", "symbols": ["_", "line"]},
    {"name": "lines$ebnf$1", "symbols": ["lines$ebnf$1", "lines$ebnf$1$subexpression$1"], "postprocess": (d) => d[0].concat([d[1]])},
    {"name": "lines", "symbols": ["line", "lines$ebnf$1"], "postprocess": d => [d[0]].concat(d[1].map((e: any) => e[1]))},
    {"name": "line$string$1", "symbols": [{"literal":"e"}, {"literal":"x"}, {"literal":"p"}, {"literal":"o"}, {"literal":"r"}, {"literal":"t"}, {"literal":"s"}, {"literal":"["}], "postprocess": (d) => d.join('')},
    {"name": "line", "symbols": ["line$string$1", "_", "string", "_", {"literal":"]"}, "_", {"literal":"="}, "_", "string", "_", {"literal":";"}], "postprocess": d => [d[2], d[8]]},
    {"name": "_$ebnf$1", "symbols": []},
    {"name": "_$ebnf$1", "symbols": ["_$ebnf$1", /[ \t\r\n]/], "postprocess": (d) => d[0].concat([d[1]])},
    {"name": "_", "symbols": ["_$ebnf$1"]},
    {"name": "string$ebnf$1", "symbols": []},
    {"name": "string$ebnf$1$subexpression$1", "symbols": ["escaped"]},
    {"name": "string$ebnf$1$subexpression$1", "symbols": [/[^`]/]},
    {"name": "string$ebnf$1", "symbols": ["string$ebnf$1", "string$ebnf$1$subexpression$1"], "postprocess": (d) => d[0].concat([d[1]])},
    {"name": "string", "symbols": [{"literal":"`"}, "string$ebnf$1", {"literal":"`"}], "postprocess": d => d[1].join("")},
    {"name": "escaped$string$1", "symbols": [{"literal":"\\"}, {"literal":"`"}], "postprocess": (d) => d.join('')},
    {"name": "escaped", "symbols": ["escaped$string$1"], "postprocess": () => "`"}
  ],
  ParserStart: "start",
};

export default grammar;
