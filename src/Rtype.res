%%raw(`
var isPrimitive = function (a) { return typeof a !== 'object'; };
var isRuntimeInterface = function (a) { return a.runtimeInterface; };
var matches = function (litOrPartial, c) {
    var matchingAlg = function (litOrPartial, c) {
        try {
            // test runtime collections of primitives
            isRuntimeInterface(litOrPartial)
                && litOrPartial.test
                && litOrPartial.test(c)
                ? litOrPartial // assoc test passed
                : isRuntimeInterface(litOrPartial)
                    && litOrPartial.test
                    && litOrPartial.test(c) === false // assoc test fail
                    ? (function () { throw 'mismatch'; })()
                    // test runtime primitives
                    : isRuntimeInterface(litOrPartial) && typeof c === litOrPartial.type
                        ? litOrPartial
                        : isRuntimeInterface(litOrPartial) && typeof c !== litOrPartial.type
                            ? (function () { throw 'mismatch'; })()
                            // test primitive literals
                            : isPrimitive(litOrPartial) && litOrPartial === c
                                ? litOrPartial
                                : isPrimitive(litOrPartial) && litOrPartial !== c
                                    ? (function () { throw 'mismatch'; })()
                                    // Recursion - either array or object
                                    : Array.isArray(litOrPartial)
                                        ? litOrPartial.map(function (item, i) { return matchingAlg(item, c[i]); })
                                        : typeof litOrPartial === 'object'
                                            ? Object.keys(litOrPartial).reduce(function (ac, cv) {
                                                return matchingAlg(litOrPartial[cv], c[cv]);
                                            }, {})
                                            // Otherwise cannot match
                                            : (function () { throw 'mismatch'; })();
            return true;
        }
        catch (e) {
            throw 'mismatch';
        }
    };
    try {
        matchingAlg(litOrPartial, c);
        return true;
    }
    catch (e) {
        return false;
    }
};
var match_ = function (litOrPartial) { return function (c) {
    return matches(litOrPartial, c)
      ? { match: true, item: c }
      : { match: false, item: undefined }
}; };
`)

type returnMatch<'rType> = { match: bool, item: 'rType }
type match<'rType, 'any> = ('rType) => ('any) => returnMatch<'rType>

@val external match: match<'rType, 'any> = "match_"

let match = (thing: 'a, rType: 'b) => match(rType)(thing)
  -> v => switch v {
  | { match: true, item: item } => Some(item)
  | { match: false, item: _ } => None
  }

// RType Interfaces

%%raw(`var $string_ = { runtimeInterface: true, type: 'string' }`)
@val external string_: string = "$string_"

%%raw(`var $number_ = { runtimeInterface: true, type: 'number' }`)
@val external number_: float = "$number_"

%%raw(`var $int_ = {
    runtimeInterface: true,
    test: function (n) { return Number.isInteger(n); }
};`)
@val external int_: int = "$int_"

%%raw(`var $gt_ = function (x) { return ({
    runtimeInterface: true,
    test: function (a) { return a > x; }
}); };`)
@val external gt_: ('a) => float = "$gt_"

%%raw(`var $gte_ = function (x) { return ({
    runtimeInterface: true,
    test: function (a) { return a >= x; }
}); };`)
@val external gte_: ('a) => float = "$gte_"

%%raw(`var $lt_ = function (x) { return ({
    runtimeInterface: true,
    type: 'number',
    test: function (a) { return a < x; }
}); };`)
@val external lt_: ('a) => float = "$lt_"

%%raw(`var $lte_ = function (x) { return ({
    runtimeInterface: true,
    test: function (a) { return a <= x; }
}); };`)
@val external lte_: ('a) => float = "$lte_"

%%raw(`var $boolean_ = { runtimeInterface: true, type: 'boolean' };`)
@val external bool_: bool = "$boolean_"

%%raw(`var $record_ = function (type_) {
  return ({
    runtimeInterface: true,
    test: function (a) {
        return typeof a === 'object'
            && Object.keys(a).map(key => {
              return match_(type_)(a[key]).match
            }).every(item => item === true);
    }
}); };`)
@val external dict_: ('a) => Js.Dict.t<'a> = "$record_"

%%raw(`var $array_ = function (type_) { return ({
    runtimeInterface: true,
    test: function (a) {
        return Array.isArray(a)
            && a.map(function (item) {
                return match_(type_)(item).match;
            }).every(function (item) { return item === true; });
    }
}); };`)
@val external array_: ('a) => array<'a> = "$array_"

// Exported RTypes

let string = string_
let float = number_
let int = int_
let gt = gt_
let gte = gte_
let lt = lt_
let lte = lte_
let bool = bool_
let dict = dict_
let array = array_

