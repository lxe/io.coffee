error during conversion: Object {
    type: IF,
    children: ,
    condition: {
        type: EQ,
        children: {
            type: IDENTIFIER,
            children: ,
            end: 21748,
            lineno: 791,
            start: 21744,
            tokenizer: [object Object],
            value: args
        },{
            type: STRING,
            children: ,
            end: 21754,
            lineno: 791,
            start: 21752,
            tokenizer: [object Object],
            value: 
        },
        end: 21754,
        lineno: 791,
        start: 21744,
        tokenizer: [object Object],
        value: ==
    },
    elsePart: {
        type: IF,
        children: ,
        condition: {
            type: AND,
            children: {
                type: EQ,
                children: {
                    type: DOT,
                    children: {
                        type: IDENTIFIER,
                        children: ,
                        end: 21776,
                        lineno: 792,
                        start: 21772,
                        tokenizer: [object Object],
                        value: args
                    },{
                        type: IDENTIFIER,
                        children: ,
                        end: 21783,
                        lineno: 792,
                        start: 21777,
                        tokenizer: [object Object],
                        value: length
                    },
                    end: 21783,
                    lineno: 792,
                    start: 21772,
                    tokenizer: [object Object],
                    value: .
                },{
                    type: NUMBER,
                    children: ,
                    end: 21788,
                    lineno: 792,
                    start: 21787,
                    tokenizer: [object Object],
                    value: 1
                },
                end: 21788,
                lineno: 792,
                parenthesized: true,
                start: 21772,
                tokenizer: [object Object],
                value: ==
            },{
                type: EQ,
                children: {
                    type: INDEX,
                    children: {
                        type: IDENTIFIER,
                        children: ,
                        end: 21798,
                        lineno: 792,
                        start: 21794,
                        tokenizer: [object Object],
                        value: args
                    },{
                        type: NUMBER,
                        children: ,
                        end: 21800,
                        lineno: 792,
                        start: 21799,
                        tokenizer: [object Object],
                        value: 0
                    },
                    end: 21800,
                    lineno: 792,
                    start: 21794,
                    tokenizer: [object Object],
                    value: [
                },{
                    type: STRING,
                    children: ,
                    end: 21808,
                    lineno: 792,
                    start: 21805,
                    tokenizer: [object Object],
                    value: -
                },
                end: 21808,
                lineno: 792,
                parenthesized: true,
                start: 21794,
                tokenizer: [object Object],
                value: ==
            },
            end: 21808,
            lineno: 792,
            start: 21772,
            tokenizer: [object Object],
            value: &&
        },
        elsePart: {
            type: IF,
            children: ,
            condition: {
                type: EQ,
                children: {
                    type: DOT,
                    children: {
                        type: IDENTIFIER,
                        children: ,
                        end: 21885,
                        lineno: 794,
                        start: 21881,
                        tokenizer: [object Object],
                        value: args
                    },{
                        type: IDENTIFIER,
                        children: ,
                        end: 21892,
                        lineno: 794,
                        start: 21886,
                        tokenizer: [object Object],
                        value: length
                    },
                    end: 21892,
                    lineno: 794,
                    start: 21881,
                    tokenizer: [object Object],
                    value: .
                },{
                    type: NUMBER,
                    children: ,
                    end: 21897,
                    lineno: 794,
                    start: 21896,
                    tokenizer: [object Object],
                    value: 2
                },
                end: 21897,
                lineno: 794,
                start: 21881,
                tokenizer: [object Object],
                value: ==
            },
            elsePart: {
                type: BLOCK,
                children: {
                    type: THROW,
                    children: ,
                    end: 22026,
                    exception: {
                        type: NEW_WITH_ARGS,
                        children: {
                            type: IDENTIFIER,
                            children: ,
                            end: 22036,
                            lineno: 798,
                            start: 22031,
                            tokenizer: [object Object],
                            value: Error
                        },{
                            type: LIST,
                            children: {
                                type: STRING,
                                children: ,
                                end: 22062,
                                lineno: 798,
                                start: 22037,
                                tokenizer: [object Object],
                                value: Invalid list arguments.
                            },
                            end: 22062,
                            lineno: 798,
                            start: 22036,
                            tokenizer: [object Object],
                            value: (
                        },
                        end: 22062,
                        lineno: 798,
                        start: 22027,
                        tokenizer: [object Object],
                        value: new
                    },
                    lineno: 798,
                    start: 22021,
                    tokenizer: [object Object],
                    value: throw
                },
                end: 22026,
                labels: [object StringMap],
                lineno: 797,
                start: 22015,
                tokenizer: [object Object],
                value: {,
                varDecls: 
            },
            end: 21879,
            labels: [object StringMap],
            lineno: 794,
            start: 21877,
            thenPart: {
                type: BLOCK,
                children: {
                    type: SEMICOLON,
                    children: ,
                    end: 21927,
                    expression: {
                        type: ASSIGN,
                        assignOp: null,
                        children: {
                            type: IDENTIFIER,
                            children: ,
                            end: 21909,
                            lineno: 795,
                            start: 21905,
                            tokenizer: [object Object],
                            value: from
                        },{
                            type: CALL,
                            children: {
                                type: IDENTIFIER,
                                children: ,
                                end: 21920,
                                lineno: 795,
                                start: 21912,
                                tokenizer: [object Object],
                                value: parseInt
                            },{
                                type: LIST,
                                children: {
                                    type: INDEX,
                                    children: {
                                        type: IDENTIFIER,
                                        children: ,
                                        end: 21925,
                                        lineno: 795,
                                        start: 21921,
                                        tokenizer: [object Object],
                                        value: args
                                    },{
                                        type: NUMBER,
                                        children: ,
                                        end: 21927,
                                        lineno: 795,
                                        start: 21926,
                                        tokenizer: [object Object],
                                        value: 0
                                    },
                                    end: 21927,
                                    lineno: 795,
                                    start: 21921,
                                    tokenizer: [object Object],
                                    value: [
                                },
                                end: 21927,
                                lineno: 795,
                                start: 21920,
                                tokenizer: [object Object],
                                value: (
                            },
                            end: 21927,
                            lineno: 795,
                            start: 21912,
                            tokenizer: [object Object],
                            value: (
                        },
                        end: 21927,
                        lineno: 794,
                        start: 21899,
                        tokenizer: [object Object],
                        value: {
                    },
                    lineno: 795,
                    start: 21905,
                    tokenizer: [object Object],
                    value: from
                },{
                    type: SEMICOLON,
                    children: ,
                    end: 21971,
                    expression: {
                        type: ASSIGN,
                        assignOp: null,
                        children: {
                            type: IDENTIFIER,
                            children: ,
                            end: 21940,
                            lineno: 796,
                            start: 21935,
                            tokenizer: [object Object],
                            value: lines
                        },{
                            type: PLUS,
                            children: {
                                type: MINUS,
                                children: {
                                    type: CALL,
                                    children: {
                                        type: IDENTIFIER,
                                        children: ,
                                        end: 21951,
                                        lineno: 796,
                                        start: 21943,
                                        tokenizer: [object Object],
                                        value: parseInt
                                    },{
                                        type: LIST,
                                        children: {
                                            type: INDEX,
                                            children: {
                                                type: IDENTIFIER,
                                                children: ,
                                                end: 21956,
                                                lineno: 796,
                                                start: 21952,
                                                tokenizer: [object Object],
                                                value: args
                                            },{
                                                type: NUMBER,
                                                children: ,
                                                end: 21958,
                                                lineno: 796,
                                                start: 21957,
                                                tokenizer: [object Object],
                                                value: 1
                                            },
                                            end: 21958,
                                            lineno: 796,
                                            start: 21952,
                                            tokenizer: [object Object],
                                            value: [
                                        },
                                        end: 21958,
                                        lineno: 796,
                                        start: 21951,
                                        tokenizer: [object Object],
                                        value: (
                                    },
                                    end: 21958,
                                    lineno: 796,
                                    start: 21943,
                                    tokenizer: [object Object],
                                    value: (
                                },{
                                    type: IDENTIFIER,
                                    children: ,
                                    end: 21967,
                                    lineno: 796,
                                    start: 21963,
                                    tokenizer: [object Object],
                                    value: from
                                },
                                end: 21967,
                                lineno: 796,
                                start: 21943,
                                tokenizer: [object Object],
                                value: -
                            },{
                                type: NUMBER,
                                children: ,
                                end: 21971,
                                lineno: 796,
                                start: 21970,
                                tokenizer: [object Object],
                                value: 1
                            },
                            end: 21971,
                            lineno: 796,
                            start: 21943,
                            tokenizer: [object Object],
                            value: +
                        },
                        end: 21971,
                        lineno: 795,
                        start: 21929,
                        tokenizer: [object Object],
                        value: ;
                    },
                    lineno: 796,
                    start: 21935,
                    tokenizer: [object Object],
                    value: lines
                },
                end: 21971,
                labels: [object StringMap],
                lineno: 794,
                start: 21899,
                tokenizer: [object Object],
                value: {,
                varDecls: 
            },
            tokenizer: [object Object],
            value: if
        },
        end: 21769,
        labels: [object StringMap],
        lineno: 792,
        start: 21767,
        thenPart: {
            type: BLOCK,
            children: {
                type: SEMICOLON,
                children: ,
                end: 21866,
                expression: {
                    type: ASSIGN,
                    assignOp: null,
                    children: {
                        type: IDENTIFIER,
                        children: ,
                        end: 21821,
                        lineno: 793,
                        start: 21817,
                        tokenizer: [object Object],
                        value: from
                    },{
                        type: MINUS,
                        children: {
                            type: DOT,
                            children: {
                                type: DOT,
                                children: {
                                    type: IDENTIFIER,
                                    children: ,
                                    end: 21829,
                                    lineno: 793,
                                    start: 21824,
                                    tokenizer: [object Object],
                                    value: Debug
                                },{
                                    type: IDENTIFIER,
                                    children: ,
                                    end: 21835,
                                    lineno: 793,
                                    start: 21830,
                                    tokenizer: [object Object],
                                    value: State
                                },
                                end: 21835,
                                lineno: 793,
                                start: 21824,
                                tokenizer: [object Object],
                                value: .
                            },{
                                type: IDENTIFIER,
                                children: ,
                                end: 21858,
                                lineno: 793,
                                start: 21836,
                                tokenizer: [object Object],
                                value: displaySourceStartLine
                            },
                            end: 21858,
                            lineno: 793,
                            start: 21824,
                            tokenizer: [object Object],
                            value: .
                        },{
                            type: IDENTIFIER,
                            children: ,
                            end: 21866,
                            lineno: 793,
                            start: 21861,
                            tokenizer: [object Object],
                            value: lines
                        },
                        end: 21866,
                        lineno: 793,
                        start: 21824,
                        tokenizer: [object Object],
                        value: -
                    },
                    end: 21866,
                    lineno: 792,
                    start: 21811,
                    tokenizer: [object Object],
                    value: {
                },
                lineno: 793,
                start: 21817,
                tokenizer: [object Object],
                value: from
            },
            end: 21866,
            labels: [object StringMap],
            lineno: 792,
            start: 21811,
            tokenizer: [object Object],
            value: {,
            varDecls: 
        },
        tokenizer: [object Object],
        value: if
    },
    end: 21742,
    labels: [object StringMap],
    lineno: 791,
    start: 21740,
    thenPart: {
        type: BLOCK,
        children: ,
        end: 21757,
        labels: [object StringMap],
        lineno: 791,
        start: 21756,
        tokenizer: [object Object],
        value: {,
        varDecls: 
    },
    tokenizer: [object Object],
    value: if
} has no method 'elsePartisA'
