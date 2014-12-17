error during conversion: Object {
    type: IF,
    children: ,
    condition: {
        type: EQ,
        children: {
            type: DOT,
            children: {
                type: IDENTIFIER,
                children: ,
                end: 1461,
                lineno: 36,
                start: 1460,
                tokenizer: [object Object],
                value: e
            },{
                type: IDENTIFIER,
                children: ,
                end: 1466,
                lineno: 36,
                start: 1462,
                tokenizer: [object Object],
                value: code
            },
            end: 1466,
            lineno: 36,
            start: 1460,
            tokenizer: [object Object],
            value: .
        },{
            type: STRING,
            children: ,
            end: 1478,
            lineno: 36,
            start: 1470,
            tokenizer: [object Object],
            value: EEXIST
        },
        end: 1478,
        lineno: 36,
        start: 1460,
        tokenizer: [object Object],
        value: ==
    },
    elsePart: {
        type: BLOCK,
        children: {
            type: SEMICOLON,
            children: ,
            end: 1526,
            expression: {
                type: CALL,
                children: {
                    type: IDENTIFIER,
                    children: ,
                    end: 1525,
                    lineno: 39,
                    start: 1518,
                    tokenizer: [object Object],
                    value: cleanup
                },{
                    type: LIST,
                    children: ,
                    end: 1526,
                    lineno: 39,
                    start: 1525,
                    tokenizer: [object Object],
                    value: (
                },
                end: 1526,
                lineno: 39,
                start: 1518,
                tokenizer: [object Object],
                value: (
            },
            lineno: 39,
            start: 1518,
            tokenizer: [object Object],
            value: cleanup
        },{
            type: THROW,
            children: ,
            end: 1540,
            exception: {
                type: IDENTIFIER,
                children: ,
                end: 1542,
                lineno: 40,
                start: 1541,
                tokenizer: [object Object],
                value: e
            },
            lineno: 40,
            start: 1535,
            tokenizer: [object Object],
            value: throw
        },
        end: 1540,
        labels: [object StringMap],
        lineno: 38,
        start: 1510,
        tokenizer: [object Object],
        value: {,
        varDecls: 
    },
    end: 1458,
    labels: [object StringMap],
    lineno: 36,
    start: 1456,
    thenPart: {
        type: BLOCK,
        children: ,
        end: 1481,
        labels: [object StringMap],
        lineno: 36,
        start: 1480,
        tokenizer: [object Object],
        value: {,
        varDecls: 
    },
    tokenizer: [object Object],
    value: if
} has no method 'elsePartisA'
