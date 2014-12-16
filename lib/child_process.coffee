error during conversion: Object {
    type: IF,
    children: ,
    condition: {
        type: IDENTIFIER,
        children: ,
        end: 19485,
        lineno: 724,
        start: 19483,
        tokenizer: [object Object],
        value: ex
    },
    elsePart: {
        type: IF,
        children: ,
        condition: {
            type: AND,
            children: {
                type: STRICT_EQ,
                children: {
                    type: IDENTIFIER,
                    children: ,
                    end: 19539,
                    lineno: 726,
                    start: 19535,
                    tokenizer: [object Object],
                    value: code
                },{
                    type: NUMBER,
                    children: ,
                    end: 19545,
                    lineno: 726,
                    start: 19544,
                    tokenizer: [object Object],
                    value: 0
                },
                end: 19545,
                lineno: 726,
                start: 19535,
                tokenizer: [object Object],
                value: ===
            },{
                type: STRICT_EQ,
                children: {
                    type: IDENTIFIER,
                    children: ,
                    end: 19555,
                    lineno: 726,
                    start: 19549,
                    tokenizer: [object Object],
                    value: signal
                },{
                    type: NULL,
                    children: ,
                    end: 19564,
                    lineno: 726,
                    start: 19560,
                    tokenizer: [object Object],
                    value: null
                },
                end: 19564,
                lineno: 726,
                start: 19549,
                tokenizer: [object Object],
                value: ===
            },
            end: 19564,
            lineno: 726,
            start: 19535,
            tokenizer: [object Object],
            value: &&
        },
        elsePart: null,
        end: 19533,
        labels: [object StringMap],
        lineno: 726,
        start: 19531,
        thenPart: {
            type: BLOCK,
            children: {
                type: SEMICOLON,
                children: ,
                end: 19603,
                expression: {
                    type: CALL,
                    children: {
                        type: IDENTIFIER,
                        children: ,
                        end: 19582,
                        lineno: 727,
                        start: 19574,
                        tokenizer: [object Object],
                        value: callback
                    },{
                        type: LIST,
                        children: {
                            type: NULL,
                            children: ,
                            end: 19587,
                            lineno: 727,
                            start: 19583,
                            tokenizer: [object Object],
                            value: null
                        },{
                            type: IDENTIFIER,
                            children: ,
                            end: 19595,
                            lineno: 727,
                            start: 19589,
                            tokenizer: [object Object],
                            value: stdout
                        },{
                            type: IDENTIFIER,
                            children: ,
                            end: 19603,
                            lineno: 727,
                            start: 19597,
                            tokenizer: [object Object],
                            value: stderr
                        },
                        end: 19603,
                        lineno: 727,
                        start: 19582,
                        tokenizer: [object Object],
                        value: (
                    },
                    end: 19603,
                    lineno: 727,
                    start: 19574,
                    tokenizer: [object Object],
                    value: (
                },
                lineno: 727,
                start: 19574,
                tokenizer: [object Object],
                value: callback
            },{
                type: RETURN,
                children: ,
                end: 19618,
                lineno: 728,
                start: 19612,
                tokenizer: [object Object],
                value: undefined
            },
            end: 19618,
            labels: [object StringMap],
            lineno: 726,
            start: 19566,
            tokenizer: [object Object],
            value: {,
            varDecls: 
        },
        tokenizer: [object Object],
        value: if
    },
    end: 19481,
    labels: [object StringMap],
    lineno: 724,
    start: 19479,
    thenPart: {
        type: BLOCK,
        children: ,
        end: 19488,
        labels: [object StringMap],
        lineno: 724,
        start: 19487,
        tokenizer: [object Object],
        value: {,
        varDecls: 
    },
    tokenizer: [object Object],
    value: if
} has no method 'elsePartisA'
