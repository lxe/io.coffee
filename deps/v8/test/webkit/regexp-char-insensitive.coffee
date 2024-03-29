# Copyright 2013 the V8 project authors. All rights reserved.
# Copyright (C) 2005, 2006, 2007, 2008, 2009 Apple Inc. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1.  Redistributions of source code must retain the above copyright
#     notice, this list of conditions and the following disclaimer.
# 2.  Redistributions in binary form must reproduce the above copyright
#     notice, this list of conditions and the following disclaimer in the
#     documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY APPLE INC. AND ITS CONTRIBUTORS ``AS IS'' AND ANY
# EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL APPLE INC. OR ITS CONTRIBUTORS BE LIABLE FOR ANY
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
# ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
description "This test checks the case-insensitive matching of character literals."
shouldBeTrue "/å/i.test('/å/')"
shouldBeTrue "/å/i.test('/Å/')"
shouldBeTrue "/Å/i.test('/å/')"
shouldBeTrue "/Å/i.test('/Å/')"
shouldBeFalse "/å/i.test('P')"
shouldBeFalse "/å/i.test('PASS')"
shouldBeFalse "/Å/i.test('P')"
shouldBeFalse "/Å/i.test('PASS')"
shouldBeNull "'PASS'.match(/Å/i)"
shouldBeNull "'PASS'.match(/Å/i)"
shouldBe "'PASå'.replace(/å/ig, 'S')", "'PASS'"
shouldBe "'PASå'.replace(/Å/ig, 'S')", "'PASS'"
shouldBe "'PASÅ'.replace(/å/ig, 'S')", "'PASS'"
shouldBe "'PASÅ'.replace(/Å/ig, 'S')", "'PASS'"
shouldBe "'PASS'.replace(/å/ig, '%C3%A5')", "'PASS'"
shouldBe "'PASS'.replace(/Å/ig, '%C3%A5')", "'PASS'"
