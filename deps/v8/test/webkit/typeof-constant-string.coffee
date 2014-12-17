error during conversion: Object {
    type: IF,
    children: ,
    condition: {
        type: EQ,
        children: {
            type: TYPEOF,
            children: {
                type: IDENTIFIER,
                children: ,
                end: 3450,
                lineno: 130,
                start: 3449,
                tokenizer: [object Object],
                value: o
            },
            end: 3450,
            lineno: 130,
            start: 3442,
            tokenizer: [object Object],
            value: typeof
        },{
            type: STRING,
            children: ,
            end: 3462,
            lineno: 130,
            start: 3454,
            tokenizer: [object Object],
            value: string
        },
        end: 3462,
        lineno: 130,
        start: 3442,
        tokenizer: [object Object],
        value: ==
    },
    elsePart: {
        type: IF,
        children: ,
        condition: {
            type: EQ,
            children: {
                type: TYPEOF,
                children: {
                    type: IDENTIFIER,
                    children: ,
                    end: 3493,
                    lineno: 131,
                    start: 3492,
                    tokenizer: [object Object],
                    value: o
                },
                end: 3493,
                lineno: 131,
                start: 3485,
                tokenizer: [object Object],
                value: typeof
            },{
                type: STRING,
                children: ,
                end: 3508,
                lineno: 131,
                start: 3497,
                tokenizer: [object Object],
                value: undefined
            },
            end: 3508,
            lineno: 131,
            start: 3485,
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
                        type: TYPEOF,
                        children: {
                            type: IDENTIFIER,
                            children: ,
                            end: 3539,
                            lineno: 132,
                            start: 3538,
                            tokenizer: [object Object],
                            value: o
                        },
                        end: 3539,
                        lineno: 132,
                        start: 3531,
                        tokenizer: [object Object],
                        value: typeof
                    },{
                        type: STRING,
                        children: ,
                        end: 3551,
                        lineno: 132,
                        start: 3543,
                        tokenizer: [object Object],
                        value: object
                    },
                    end: 3551,
                    lineno: 132,
                    start: 3531,
                    tokenizer: [object Object],
                    value: ==
                },{
                    type: EQ,
                    children: {
                        type: TYPEOF,
                        children: {
                            type: INDEX,
                            children: {
                                type: IDENTIFIER,
                                children: ,
                                end: 3563,
                                lineno: 132,
                                start: 3562,
                                tokenizer: [object Object],
                                value: o
                            },{
                                type: NUMBER,
                                children: ,
                                end: 3565,
                                lineno: 132,
                                start: 3564,
                                tokenizer: [object Object],
                                value: 0
                            },
                            end: 3565,
                            lineno: 132,
                            start: 3562,
                            tokenizer: [object Object],
                            value: [
                        },
                        end: 3565,
                        lineno: 132,
                        start: 3555,
                        tokenizer: [object Object],
                        value: typeof
                    },{
                        type: STRING,
                        children: ,
                        end: 3578,
                        lineno: 132,
                        start: 3570,
                        tokenizer: [object Object],
                        value: string
                    },
                    end: 3578,
                    lineno: 132,
                    start: 3555,
                    tokenizer: [object Object],
                    value: ==
                },
                end: 3578,
                lineno: 132,
                start: 3531,
                tokenizer: [object Object],
                value: &&
            },
            elsePart: null,
            end: 3529,
            labels: [object StringMap],
            lineno: 132,
            start: 3527,
            thenPart: {
                type: BLOCK,
                children: {
                    type: RETURN,
                    children: ,
                    end: 3600,
                    lineno: 133,
                    start: 3594,
                    tokenizer: [object Object],
                    value: {
                        type: STRING,
                        children: ,
                        end: 3607,
                        lineno: 133,
                        start: 3601,
                        tokenizer: [object Object],
                        value: PASS
                    }
                },
                end: 3600,
                labels: [object StringMap],
                lineno: 132,
                start: 3580,
                tokenizer: [object Object],
                value: {,
                varDecls: 
            },
            tokenizer: [object Object],
            value: if
        },
        end: 3483,
        labels: [object StringMap],
        lineno: 131,
        start: 3481,
        thenPart: {
            type: BLOCK,
            children: ,
            end: 3511,
            labels: [object StringMap],
            lineno: 131,
            start: 3510,
            tokenizer: [object Object],
            value: {,
            varDecls: 
        },
        tokenizer: [object Object],
        value: if
    },
    end: 3440,
    labels: [object StringMap],
    lineno: 130,
    start: 3438,
    thenPart: {
        type: BLOCK,
        children: ,
        end: 3465,
        labels: [object StringMap],
        lineno: 130,
        start: 3464,
        tokenizer: [object Object],
        value: {,
        varDecls: 
    },
    tokenizer: [object Object],
    value: if
} has no method 'elsePartisA'
