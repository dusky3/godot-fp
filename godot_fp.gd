@tool
class_name FP extends Node

enum TYPE {
	EITHER		= 0,
	FREE		= 1,
	IDENTITY 	= 2,
	IO			= 3,
	LIST 		= 4,
	MAYBE 		= 5,
	MONADT		= 6,
	READER		= 7,
	NEL 		= 8,
	VALIDATION 	= 9
}

class Arr:

	static func assign(target: Array = [], source: Array = [], duplicate: bool = true, duplicate_deep: bool = true) -> Array:
		var _target: Array = target.duplicate(duplicate_deep) if duplicate else target
		_target.assign(source)
		return _target

	static func assign_left(target: Array = [], source: Array = [], duplicate: bool = true, duplicate_deep: bool = true) -> Array:
		var _source: Array = source.duplicate(duplicate_deep) if duplicate else source
		_source.assign(target)
		return _source

	static func join(arr: Array = [], separator: String = ", ") -> String:
		var t: String = ""
		if arr.size() > 0:
			for i in arr.size()-1: t += str(arr[i])+separator
			t += str(arr[-1])
			return t
		else: return t

	static func reduce(f: Callable = Callable(), acc: Variant = null, arr: Array = [], duplicate: bool = true) -> Variant:
		var _arr: Array = arr.duplicate() if duplicate else arr
		var res = _arr.reduce(f, acc)
		return res

	static func reduce_right(f: Callable = Callable(), acc: Variant = null, arr: Array = [], duplicate: bool = true) -> Variant:
		var _arr: Array = arr.duplicate() if duplicate else arr
		var res = Arr.reverse(_arr).reduce(f, acc)
		return res

	static func reverse(arr: Array, duplicate: bool = true, duplicate_deep: bool = true) -> Array:
		var _arr: Array = arr.duplicate(duplicate_deep)
		_arr.reverse()
		return _arr

class Dict:

		
	static func assign(target: Dictionary = {}, source: Dictionary = {},  overwrite: bool = true, duplicate: bool = true, duplicate_deep: bool = true) -> Dictionary:
		var _target: Dictionary = target.duplicate(duplicate_deep) if duplicate else target
		_target.merge(source, overwrite)
		return _target

	static func assign_left(target: Dictionary = {}, source: Dictionary = {}, overwrite: bool = true, duplicate: bool = true, duplicate_deep: bool = true) -> Dictionary:
		var _source: Dictionary = source.duplicate(duplicate_deep) if duplicate else source
		_source.merge(target, overwrite)
		return _source

	static func merge(target: Dictionary = {}, source: Dictionary = {},  overwrite: bool = true, duplicate: bool = true, duplicate_deep: bool = true) -> Dictionary:
		var _target: Dictionary = target.duplicate(duplicate_deep) if duplicate else target
		_target.merge(source, overwrite)
		return _target

	static func merge_left(target: Dictionary = {}, source: Dictionary = {}, overwrite: bool = true, duplicate: bool = true, duplicate_deep: bool = true) -> Dictionary:
		var _source: Dictionary = source.duplicate(duplicate_deep) if duplicate else source
		_source.merge(target, overwrite)
		return _source

class __utils__:

	static func cons(head: Variant = null, tail: List = FP.Nil) -> List:
		return tail.cons(head)

	static func Either_is_of_type(other_type: TYPE) -> Callable:
		return FP.is_of_type(TYPE.EITHER)

	static func Free_is_of_type(other_type: TYPE) -> Callable:
		return FP.is_of_type(TYPE.FREE)

	static func Identity_is_of_type(other_type: TYPE) -> Callable:
		return FP.is_of_type(TYPE.IDENTITY)

	static func IO_is_of_type(other_type: TYPE) -> Callable:
		return FP.is_of_type(TYPE.IO)

	static func list_ap(l1: Variant = null, l2: Variant = null) -> Variant:
		return l1.bind(func(x) -> Variant:
			return l2.map(func(f) -> Variant: return f.call(x)))

	static func list_contains(l: Variant = null, val = null) -> bool:
		return list_contains_curried(l, val).run()

	static func list_contains_curried(l: Variant = null, val = FP.Nil) -> Variant:
		if l.is_Nil: return FP.Return(false)
		var h = l.head()
		return FP.Return(true) if FP.are_equal(h, val) else FP.Suspend(func():
			return list_contains_curried(l.tail(), val))

	static func list_equals(l1: Variant = null, l2: Variant = null) -> bool:
		var a: Variant = l1; var b: Variant = l2
		while !a.is_Nil and !b.is_Nil:
			if !FP.equals(a.head()).call(b.head()): return false
			a = a.tail(); b = b.tail()
		return a.is_Nil and b.is_Nil

	static func list_filter(l: Variant = null, f: Callable = Callable()) -> Variant:
		return l.foldRight(FP.Nil).call(func(a, acc): return cons(a, acc) if f.call(a) else acc)

	static func list_find(l: Variant = null, f: Callable = Callable()) -> Variant:
		return list_find_curried(l, f).run()

	static func list_find_curried(l: Variant = null, f: Callable = Callable()) -> Variant:
		if l.is_Nil: return FP.Return(FP.Nothing())
		var h = l.head()
		return FP.Return(FP.Just(h)) if f.call(h) else FP.Suspend(func():
			return list_find_curried(l.tail(), f))

	static func list_fold_left(f: Callable = Callable(), acc: Variant = null, l:Variant = null) -> Variant:
		var fl: Callable
		fl = func(_acc, _l: List) -> Free: return FP.Return(_acc) if _l.is_Nil else FP.Suspend(func() -> Variant:
			return fl.call(f.call(_acc, _l.head()), _l.tail()))
		return fl.call(acc, l).run()

	static func list_fold_right(f: Callable = Callable(), l:Variant = null, acc: Variant = null) -> Variant:
		var fr: Callable
		fr = func(_l: List, _acc) -> Free: return FP.Return(_acc) if _l.is_Nil else FP.Suspend(func() -> Variant:
			return fr.call(_l.tail(), _acc).map(func(accum) -> Variant:
				return f.call(_l.head(), accum))) return fr.call(l, acc).run()

	static func list_for_each(f:Callable = Callable(), l: List = FP.Nil):
		if !l.is_Nil: f.call(l.head()); list_for_each(f, l.tail())

	static func List_is_of_type(other_type: TYPE) -> Callable:
		return FP.is_of_type(TYPE.LIST)

	static func list_map(f: Callable = Callable(), l: Variant = null) -> List:
		return list_map_curried(f, l).run()

	static func list_map_curried(f: Callable = Callable(), l: Variant = null) -> Variant:
		return FP.Return(l) if l.is_Nil else FP.Suspend(func():
			return list_map_curried(f, l.tail())).map(FP.curry2(__utils__.cons).call(f.call(l.head())))

	static func map2(f: Callable = Callable()) -> Variant: return func(ma, mb) -> Variant:
		return ma.flat_map(func(a) -> Variant: return mb.map(func(b) -> Variant: return f.call(a, b)))

	static func MonadT_is_of_type(other_type: TYPE) -> Callable:
		return FP.is_of_type(TYPE.MONADT)

	static func list_reverse(l: List = FP.Nil) -> List:
		return l.fold_left(FP.Nil).call(FP.swap2(__utils__.cons))

	static func NEL_is_of_type(other_type: TYPE) -> Callable:
		return FP.is_of_type(TYPE.NEL)

	static func Maybe_is_of_type(other_type: TYPE) -> Callable:
		return FP.is_of_type(TYPE.MAYBE)

	static func Reader_is_of_type(other_type: TYPE) -> Callable:
		return FP.is_of_type(TYPE.READER)
	
	static func sequence(l: List = FP.Nil, monad_type: TYPE = TYPE.MAYBE) -> Variant:
		match monad_type:
			TYPE.EITHER		: return l.fold_right(Either.of(FP.Nil)).call(__utils__.map2(__utils__.cons))
			TYPE.FREE		: return l.fold_right(Free.of(FP.Nil)).call(__utils__.map2(__utils__.cons))
			TYPE.IDENTITY	: return l.fold_right(Identity.of(FP.Nil)).call(__utils__.map2(__utils__.cons))
			TYPE.IO			: return l.fold_right(IO.of(FP.Nil)).call(__utils__.map2(__utils__.cons))
			TYPE.LIST		: return l.fold_right(List.of(FP.Nil)).call(__utils__.map2(__utils__.cons))
			TYPE.MAYBE		: return l.fold_right(Maybe.of(FP.Nil)).call(__utils__.map2(__utils__.cons))
			TYPE.MONADT		: return l.fold_right(MonadT.of(FP.Nil)).call(__utils__.map2(__utils__.cons))
			TYPE.NEL		: return l.fold_right(NEL.of(FP.Nil)).call(__utils__.map2(__utils__.cons))
			TYPE.READER		: return l.fold_right(Reader.of(FP.Nil)).call(__utils__.map2(__utils__.cons))
			TYPE.VALIDATION	: return l.fold_right(Validation.of(FP.Nil)).call(__utils__.map2(__utils__.cons))
			_				: push_error(monad_type," is not a valid Monad type (not a member of TYPE enum)."); return

	static func sequence_validation(l: List = FP.Nil) -> Variant:
		return l.fold_left(FP.Success(FP.Nil)).call(func(acc: Variant = null, a: Variant = null):
			return acc.ap(a.map(func(v) -> Variant: return func(t) -> Variant: return cons(v, t)))).map(__utils__.list_reverse)

	static func Validation_is_of_type(other_type: TYPE) -> Callable:
		return FP.is_of_type(TYPE.VALIDATION)

# FP
static var Nil = List.new()

static func always(a: Variant = null) -> Callable:
	return FP.Y.K(a)

static func append(this: List = Nil, other: List = Nil) -> Variant:
		var af: Callable
		af = func(l1: List, l2: List):
			return FP.Return((l2) if l1.is_Nil else FP.Suspend(func() -> Variant:
				return af.call(l1.tail(), l2).map(func(l) -> Variant:
					return l.cons(l1.head()))) )
		return af.call(this, other).run()

static func apply2(a1: Variant = null, a2: Variant = null, f:Callable = Callable()) -> Variant:
	return a2.ap(a1.map(curry2(f)))

static func are_equal(a: Variant = null, b: Variant = null) -> bool:
	if !a or !b						: return false
	if is_integer(a)				: a = float(a)
	if is_integer(b)				: b = float(b)
	if is_same(a, b)				: return true
	if is_object(a) and is_object(b): return a.equals(b) if is_function(a.equals) and is_function(b.equals) else false
	else							: return false

static func compose(f0: Callable = Callable(), f1: Callable = Callable(), f2: Callable = Callable(),\
					f3: Callable = Callable(),	f4: Callable = Callable(), f5: Callable = Callable(),\
					f6: Callable = Callable(),	f7: Callable = Callable(), f8: Callable = Callable(),\
					f9: Callable = Callable()) -> Callable:
	var fs_array: Array = Arr.reverse([f0, f1, f2, f3, f4, f5, f6, f7, f8, f9]).filter(func(x):return x and x != null)
	return func(a0 = null, a1 = null, a2 = null,a3 = null, a4 = null, a5 = null,\
				a6 = null, a7 = null, a8 = null, a9 = null) -> Variant:
		var args_array: Array = [a0, a1, a2, a3, a4, a5, a6, a7, a8, a9].filter(func(x):return x and x != null)
		return fs_array.slice(1).reduce(func(acc,f):return f.call(acc), fs_array[0].callv(args_array))

static func compose_left(f0: Callable = Callable(), f1: Callable = Callable(), f2: Callable = Callable(),\
					f3: Callable = Callable(),	f4: Callable = Callable(), f5: Callable = Callable(),\
					f6: Callable = Callable(),	f7: Callable = Callable(), f8: Callable = Callable(),\
					f9: Callable = Callable()) -> Callable:
	var fs_array: Array = [f0, f1, f2, f3, f4, f5, f6, f7, f8, f9].filter(func(x):return x and x != null)
	return func(a0 = null, a1 = null, a2 = null,a3 = null, a4 = null, a5 = null,\
				a6 = null, a7 = null, a8 = null, a9 = null) -> Variant:
		var args_array: Array = [a0, a1, a2, a3, a4, a5, a6, a7, a8, a9].filter(func(x):return x and x != null)
		return fs_array.slice(1).reduce(func(acc,f):return f.call(acc), fs_array[0].callv(args_array))

static func compose2(f: Callable = Callable(), g: Callable = Callable()) -> Callable:
	return func composed2(x = null) -> Variant:
		return f.call(g.call(x))

static func compose2_left(f: Callable = Callable(), g: Callable = Callable()) -> Callable:
	return swap2(compose2).call(f, g)

static func curry(arity: int, f: Callable, arg0 = null, arg1 = null, arg2 = null, arg3 = null, arg4 = null,\
				 arg5 = null,	arg6 = null, arg7 = null, arg8 = null, arg9 = null) -> Variant:
	var args_array: Array = [arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9].filter(func(x):return x and x != null)
	if arity - args_array.size()  == 0: return f.callv(args_array)
	else:
		return func curried(a0 = null, a1 = null, a2 = null,a3 = null, a4 = null, a5 = null,\
							a6 = null, a7 = null, a8 = null, a9 = null) -> Variant:
			var _args_array: Array = [a0, a1, a2, a3, a4, a5, a6, a7, a8, a9].filter(func(x):return x and x != null)
			var next_args: Array = args_array +_args_array
			var remaining: int = arity - next_args.size()
			return curry(remaining, f.bindv(next_args)) if remaining > 0 else f.callv(next_args.slice(0, arity))

static func curry2(f: Callable, arg: Variant = null, arg1: Variant = null) -> Variant:
	if arg and arg1	: return f.call(arg, arg1)
	elif arg		: return func _curried2_with_one_argument(_arg: Variant) -> Variant: return f.call(arg, _arg)
	else			: return func _curried2(_arg: Variant) -> Callable:
						return func _curried2_with_one_argument(_arg1: Variant) -> Variant: return f.call(_arg, _arg1)

static func Either_of(a: Variant = null) -> Either:
	return Right(a)

static func equals(a: Variant = null) -> Callable:
	return func(b) -> bool: return are_equal(a, b)

static func F(val: bool = false) -> Callable:
	return always(false)

static func Fail(err: Variant = null) -> Validation:
	return Validation.new(err, false)

static func false_function() -> bool:
	return false

static func Free_lift_f(functor_: Variant = null) -> Free: 
	return Suspend(FP.compose2(Return, functor_)) if FP.is_function(functor_) else Suspend(functor_.map(Return))
	
static func Free_of(a: Variant = null) -> Free:
	return Return(a)

static func Free_point(a: Variant = null) -> Free:
	return Return(a)
	
static func Free_pure(a: Variant = null) -> Free:
	return Return(a)
	
static func Free_unit(a: Variant = null) -> Free:
	return Return(a)

static func Identity_(a: Variant = null) -> Identity:
	return Identity.new(a)

static func Identity_of(a: Variant = null) -> Identity:
	return Identity.new(a)

static func is_empty(val = null) -> bool:
	if typeof(val) == TYPE_ARRAY		: return true if val == [] else false
	if typeof(val) == TYPE_CALLABLE		: return true if val == Callable() else false
	if typeof(val) == TYPE_DICTIONARY	: return true if val == {} else false
	if typeof(val) == TYPE_STRING		: return true if val == "" else false
	else								: return is_nothing(val)

static func is_falsy(val: Variant = null) -> bool:
	return true if !val else false

static func id_function(val: Variant = null) -> Variant:
	return val

static func IO_(effect_f_: Callable = Callable()) -> IO:
	return IO.new(effect_f_)

static func IO_of(a: Variant = null) -> IO:
	return IO.new(func() -> Variant: return a)

static func is_function(f: Variant = null) -> bool:
	return typeof(f) == TYPE_CALLABLE

static func is_integer(i: Variant = null) -> bool:
	return typeof(i) == TYPE_INT

static func is_nothing(val: Variant = null) -> bool:
	return true if val == null else false

static func is_object(o: Variant = null) -> bool:
	return typeof(o) == TYPE_OBJECT

static func is_of_type(type_name: TYPE = TYPE.FREE) -> Callable:
	return func(target: Variant = null) -> bool:
		return type_name == target.TYPE_KEY

static func Just(val: Variant = null) -> Maybe:
	return Maybe.new(true, val)

static func Left(val: Variant = null) -> Either:
	return Either.new(val, false)

static func List_(head = null, tail: List = Nil) -> List:
	if head and tail	: return List.new(head, tail)
	elif head			: return List.new(head)
	else				: return List.new()

static func List_empty() -> List:
	return Nil

static func List_from_array(arr: Array = []) -> List:
	return Arr.reduce_right(func(acc, next): return acc.cons(next), Nil, arr)

# alias for List_unit
static func List_of(val: Variant = null) -> List:
	return List.new(val, Nil)

# alias for List_unit
static func List_point(val: Variant = null) -> List:
	return List.new(val, Nil)

static func List_pure(val: Variant = null) -> List:
	return List.new(val, Nil)

# alias for List_unit
static func List_unit(val: Variant = null) -> List:
	return List.new(val, Nil)

""" static func Maybe_(is_value: bool = true, val: Variant = null) -> Maybe:
	return Maybe.new(is_value, val) """

static func Maybe_from_empty(val: Variant = null) -> Maybe:
	return Nothing() if is_empty(val) else Just(val)

static func Maybe_from_falsy(val: Variant = null) -> Maybe:
	return Nothing() if !val else Just(val)

static func Maybe_from_null(val: Variant = null) -> Maybe:
	return Nothing() if is_nothing(val) else Just(val)

static func Maybe_of(a: Variant = null) -> Maybe:
	return Just(a)

static func Maybe_point(a: Variant = null) -> Maybe:
	return Just(a)

static func Maybe_pure(a: Variant = null) -> Maybe:
	return Just(a)

static func Maybe_unit(a: Variant = null) -> Maybe:
	return Just(a)

static func Maybe_to_list(m: Maybe = Nothing()) -> List:
	return m.to_list()

static func MonadT_of(monad: Variant = null) -> MonadT: 
	return MonadT.new(monad)

static func MonadT_point(monad: Variant = null) -> MonadT: 
	return MonadT.new(monad)

static func MonadT_pure(monad: Variant = null) -> MonadT: 
	return MonadT.new(monad)

static func MonadT_unit(monad: Variant = null) -> MonadT: 
	return MonadT.new(monad)

static func MonadT_(monad: Variant = null) -> MonadT: 
	return MonadT.new(monad)

static func monad_transformer(monad: Variant = null) -> MonadT: 
	return MonadT.new(monad)

static func NEL_(head = null, tail: List = Nil) -> void:
	push_error("Can't create empty Non-Empty List. Passed head is " + head + ".") if is_nothing(head) else NEL.new(head, tail)

static func NEL_from_array(arr: Array = []) -> Maybe:
	return NEL_from_list(List.from_array(arr))

static func NEL_from_list(l: List = FP.Nil) -> Maybe:
	return FP.Nothing() if l.is_nil else FP.Just(NEL.new(l.head(), l.tail()))

static func NEL_of(val: Variant = null) -> NEL:
	return NEL.new(val, FP.Nil)

static func NEL_point(val: Variant = null) -> NEL:
	return NEL.new(val, FP.Nil)

static func NEL_pure(val: Variant = null) -> NEL:
	return NEL.new(val, FP.Nil)

static func NEL_unit(val: Variant = null) -> NEL:
	return NEL.new(val, FP.Nil)

static func None() -> Maybe:
	return Maybe.new()

static func noop() -> void:
	pass

static func Nothing() -> Maybe:
	return Maybe.new()

static func Reader_(f: Callable = Callable()) -> Reader:
	return Reader.new(f)

static func Reader_ask() -> Reader:
	return Reader.new(FP.id_function)

static func Reader_of(a: Variant = null) -> Reader:
	return Reader.new(func(b: Variant = null) -> Variant: return a) #b is for currying purpses

static func Return(val: Variant = null) -> Free:
	return Free.new(val, false)

static func Right(val: Variant = null) -> Either:
	return Either.new(val, true)

static func Semigroup_append(a: Variant = null, b: Variant = null) -> Variant:
	if FP.is_function(a.concat):
		return a.concat(b)
	else:
		push_error("Could not find a semigroup appender in the environment, " + "please specify your own append function"); return

static func Some(val: Variant = null) -> Maybe:
	return Maybe.new(true, val)

static func Success(val: Variant = null) -> Validation:
	return Validation.new(val, true)

static func Suspend(functor: Variant = null) -> Free:
	return Free.new(functor, true)

static func swap(f: Callable = Callable()) -> Callable:
	return func swapped(a0 = null, a1 = null, a2 = null,a3 = null, a4 = null, a5 = null,\
						a6 = null, a7 = null, a8 = null, a9 = null) -> Variant:
		return f.callv(Arr.reverse([a0, a1, a2, a3, a4, a5, a6, a7, a8, a9].filter(func(x):return x and x != null)))

static func swap2(f: Callable = Callable()) -> Callable:
	return func swapped2(a: Variant = null, b: Variant = null) -> Variant: return f.call(b, a)

static func T(val: bool = true) -> Callable:
	return always(true)

static func true_function() -> bool:
	return true

static func Validation_(val: Variant = null, success: bool = false) -> Validation:
	return Validation.new(val, success)

static func Validation_Fail(err: Variant = null) -> Validation:
	return Validation.new(err, false)

static func Validation_of(v: Variant = null) -> Validation:
	return FP.Success(v)

static func Validation_Success(val: Variant = null) -> Validation:
	return Validation.new(val, true)

#MONAD CLASSES

class Either:

	const TYPE_KEY: TYPE = TYPE.EITHER

	static var _max_id 	: int = 0
	var id 				: int
	var is_right_value	: bool
	var value			: Variant
	
	static func is_of_type(other_type: TYPE) -> Callable:
		return FP.is_of_type(TYPE.EITHER)

	static func Left(val: Variant = null) -> Either:
		return Either.new(val, false)

	static func of(a: Variant = null) -> Either:
		return Right(a)

	static func point(a: Variant = null) -> Either:
		return Right(a)

	static func pure(a: Variant = null) -> Either:
		return Right(a)

	static func unit(a: Variant = null) -> Either:
		return Right(a)

	static func Right(val: Variant = null) -> Either:
		return Either.new(val, true)

	func _init(val_: Variant = null, is_right_value_: bool = false) -> void:
		_max_id += 1
		id = _max_id
		is_right_value = is_right_value_
		value = val_


	func ap(either_with_f: Either = null) -> Variant: 
		var this = self
		return either_with_f.map(func(f): return f.call(this.value)) if is_right_value else self

	func ap_to(either_with_value: Either = null) -> Variant: 
		return either_with_value.ap(self)

	func bimap(left_f: Callable = Callable(), right_f: Callable = Callable()) -> Variant: 
		return map(right_f) if is_right_value else left_map(left_f)

	func bind(f: Callable = Callable()) -> Variant:
		return f.call(value) if is_right_value else self

	func cata(left_f: Callable = Callable(), right_f: Callable = Callable()) -> Variant: 
		return right_f.call(value) if is_right_value else left_f.call(value)

	func catch_map(f: Callable = Callable()) -> Variant:
		return self if is_Right() else f.call(value)

	func chain(f: Callable = Callable()) -> Variant:
		return f.call(value) if is_right_value else self

	func equals(other: Variant = null) -> bool: 
		return Either.is_of_type(other) and cata(
			func(left: Variant = null) -> Variant: return other.cata(equals(left), FP.false_function),
			func(right: Variant = null) -> Variant: return other.cata(FP.false_function, equals(right)))
			
	func flat_map(f: Callable = Callable()) -> Variant:
		return f.call(value) if is_right_value else self

	func inspect() -> String: 
		return to_String()

	func is_Left() -> bool: 
		return !is_Right()

	func is_Right() -> bool: 
		return is_right_value

	func join() -> Variant:
		return flat_map(FP.id_function)

	func fold(left_f, right_f) -> Variant: 
		return right_f.call(value) if is_right_value else left_f.call(value)

	func fold_left(initial_value: Variant = null) -> Variant: 
		return to_Maybe().to_List().fold_left(initial_value)

	func fold_right(initial_value: Variant = null) -> Variant: 
		return to_Maybe().to_List().fold_right(initial_value)

	func for_each(f: Callable = Callable()) -> void:
		cata(FP.noop, f)

	func for_each_left(f: Callable = Callable()) -> void:
		cata(f, FP.noop)

	func left(): 
		if is_right_value: push_error("Can not call left() on Right.")
		return value

	func left_map(f) -> Variant: 
		return FP.Left(f.call(value)) if is_Left() else self

	func map(f: Callable = Callable()) -> Variant:
		return bind(FP.compose2(of, f))

	func right(): 
		if is_right_value: return value
		push_error("Can not call right() on Left.")

	func swap() -> Either: 
		return Left(value) if is_Right() else Right(value)

	func take_left(m: Variant = null) -> Variant:
		return FP.apply2(self, m, FP.Y.K)
	
	func take_right(m: Variant = null) -> Variant:
		return FP.apply2(self, m, FP.Y.KI)
			
	func to_Maybe() -> Maybe: 
		return FP.Just(value) if is_Right() else FP.Nothing()

	func to_String() -> String: 
		return cata(
			func(left: Variant = null) -> String: return "Left(" + left + ")",
			func(right: Variant = null) -> String: return "Right(" + right + ")")

	func to_Validation() -> Validation: 
		return FP.Success(value) if is_Right() else FP.Fail(value)

class Free:

	const TYPE_KEY: TYPE = TYPE.FREE

	static var _max_id 	: int = 0
	var id 				: int
	var val				: Variant
	var functor			: Variant
	var is_suspend		: bool
	
	static func is_of_type(other_type: TYPE) -> Callable:
		return FP.is_of_type(TYPE.FREE)

	static func lift_f(functor_: Variant = null) -> Free: 
		return Suspend(FP.compose2(Return, functor_)) if FP.is_function(functor_) else Suspend(functor_.map(Return))
	
	static func of(a: Variant = null) -> Free:
		return Return(a)

	static func point(a: Variant = null) -> Free:
		return Return(a)
	
	static func pure(a: Variant = null) -> Free:
		return Return(a)
	
	static func unit(a: Variant = null) -> Free:
		return Return(a)

	static func Return(val: Variant = null) -> Free:
		return Free.new(val, false)

	static func Suspend(functor_: Variant = null) -> Free:
		return Free.new(functor_, true)

	func _init(val_: Variant = null, is_suspend_:bool = false) -> void:
		_max_id += 1
		id = _max_id
		is_suspend = is_suspend_
		if is_suspend: functor = val_
		else: val = val_
	
	func ap(free_with_f: Free = null) -> Variant:
		return bind(func(x: Variant = null) -> Variant: 
			return free_with_f.map(func(f: Callable = Callable()) -> Variant: return f.call(x)))
	
	func ap_to(free_with_value: Free = null) -> Variant:
		return free_with_value.ap(self)
	
	func bind(f: Callable = Callable()) -> Variant:
		if is_suspend:
			if FP.is_function(functor):
				return Suspend(FP.compose2(func(free: Free = null) -> Variant: return free.bind(f) , functor))
			else:
				return Suspend(functor.map(func(free: Free = null) -> Variant: return free.bind(f)))
		else:
			return f.call(val)

	func chain(f: Callable = Callable()) -> Variant:
		if is_suspend:
			if FP.is_function(functor):
				return Suspend(FP.compose2(func(free: Free = null) -> Variant: return free.bind(f) , functor))
			else:
				return Suspend(functor.map(func(free: Free = null) -> Variant: return free.bind(f)))
		else:
			return f.call(val)

	func flat_map(f: Callable = Callable()) -> Variant:
		if is_suspend:
			if FP.is_function(functor):
				return Suspend(FP.compose2(func(free: Free = null) -> Variant: return free.bind(f) , functor))
			else:
				return Suspend(functor.map(func(free: Free = null) -> Variant: return free.bind(f)))
		else:
			return f.call(val)

	func go(functor: Variant = null): 
		var result = self.resume()
		while result.isLeft(): 
			var next = functor.call(result.left())
			result = next.resume()
		return result.right()

	func go1(functor_: Variant = null) -> Variant: 
		var go2: Callable
		go2 = func(functor1: Variant = null) -> Variant: return functor1.resume().cata(func(functor) -> Variant: return go2.call(functor_.call(functor)), FP.id_function)
		return go2.call(self)

	func join() -> Variant:
		return flat_map(FP.id_function)

	func map(f: Callable = Callable()) -> Variant:
		return bind(FP.compose2(of, f))

	func resume() -> Either: 
		return FP.Left(functor) if is_suspend else FP.Right(val)

	func run() -> Either:
		return go(func(f: Callable = Callable()) -> Variant:
			return f.call())

	func take_left(m: Variant = null) -> Variant:
		return FP.apply2(self, m, FP.Y.K)
	
	func take_right(m: Variant = null) -> Variant:
		return FP.apply2(self, m, FP.Y.KI)
			
class Identity:

	const TYPE_KEY: TYPE = TYPE.IDENTITY

	static var _max_id	: int = 0
	var id				: int
	var val				: Variant
	
	static func is_of_type(other_type: TYPE) -> Callable:
		return FP.is_of_type(TYPE.IDENTITY)

	static func of(a: Variant = null) -> Identity:
		return Identity.new(a)

	static func point(a: Variant = null) -> Identity:
		return Identity.new(a)

	static func pure(a: Variant = null) -> Identity:
		return Identity.new(a)

	static func unit(a: Variant = null) -> Identity:
		return Identity.new(a)

	func _init(val_: Variant = null) -> void:
		_max_id += 1
		id = _max_id
		val = val_

	func ap(apply_with_f: Variant = null) -> Variant: 
		var value = val
		return apply_with_f.map(func(f: Callable = Callable()) -> Variant: return f.call(value))

	func ap_to(identity_with_value: Identity = null) -> Variant: 
		return identity_with_value.ap(self)
	
	func bind(f: Callable = Callable()) -> Variant: 
		return f.call(val)
	
	func chain(f: Callable = Callable()) -> Variant: 
		return f.call(val)
	
	func flat_map(f: Callable = Callable()) -> Variant: 
		return f.call(val)
	
	func for_all(f: Callable = Callable()) -> bool:
		return to_Array().all(f)

	func contains(val_) -> bool: 
		return FP.are_equal(val, val_)
	
	func equals(other: Variant = null) -> bool: 
		return __utils__.Identity_is_of_type(other) and FP.equals(get_value()).call(other.get_value())
	
	func exists(f: Callable = Callable()) -> bool:
		return to_Array().any(f)

	func for_each(f: Callable = Callable()) -> void: 
		f.call(val)
	
	func get_value() -> Variant: 
		return val
	
	func inspect() -> String: 
		return to_string()
	
	func join() -> Variant:
		return flat_map(FP.id_function)

	func map(f: Callable = Callable()) -> Variant:
		return bind(FP.compose2(of, f))

	func take_left(m: Variant = null) -> Variant:
		return FP.apply2(self, m, FP.Y.K)
	
	func take_right(m: Variant = null) -> Variant:
		return FP.apply2(self, m, FP.Y.KI)
			
	func to(functor: Variant = null) -> Variant:
		return functor.new(self)

	func to_Array() -> Array: 
		return [get_value()]
	
	func to_List() -> List: 
		return List.new(get_value(), FP.Nil)

	func to_String() -> String: 
		return "Identity(" + val + ")"
	
class IO:

	const TYPE_KEY: TYPE = TYPE.IO

	static var _max_id	: int = 0
	var id 				: int
	var effect_f		: Callable
	
	static func is_of_type(other_type: TYPE) -> Callable:
		return FP.is_of_type(TYPE.IO)

	static func of(a: Variant = null) -> Variant:
		return IO.new(func() -> Variant: return a)

	func _init(effect_f_: Callable = Callable()) -> void:
		_max_id += 1
		id = _max_id
		effect_f = effect_f_

	func ap(io_with_f: IO = null) -> Variant: 
		var this = self
		return io_with_f.map(func(f: Callable = Callable()) -> Variant:
			return f.call(this.effect_fn.call()))
	
	func ap_to(io_with_value: IO = null) -> Variant:
		return io_with_value.ap(self)

	func bind(f: Callable = Callable()) -> IO:
		var this = self
		return IO.new(func() -> Variant:
			return f.call(this.effect_f.call())).run()
	
	func chain(f: Callable = Callable()) -> IO:
		var this = self
		return IO.new(func() -> Variant:
			return f.call(this.effect_f.call())).run()
	
	func flat_map(f: Callable = Callable()) -> IO:
		var this = self
		return IO.new(func() -> Variant:
			return f.call(this.effect_f.call())).run()
	
	func join() -> Variant:
		return flat_map(FP.id_function)
	
	func map(f: Callable = Callable()) -> IO: 
		var this = self
		return IO.new(func() -> Variant:
			return f.call(this.effect_f.call()))
	
	func perform(): 
		return effect_f.call()
		
	func run(): 
		return effect_f.call()

	func take_left(m: Variant = null) -> Variant:
		return FP.apply2(self, m, FP.Y.K)

	func take_right(m: Variant = null) -> Variant:
		return FP.apply2(self, m, FP.Y.KI)

class List:

	const TYPE_KEY: TYPE = TYPE.LIST

	static var _max_id	: int = 0
	var id 				: int
	var is_Nil			: bool
	var head_			: Variant
	var tail_			: List
	var size_			: int

	static func empty() -> List:
		return FP.Nil

	static func from_array(arr: Array = []) -> List:
		return Arr.reduce_right(func(acc, next):return acc.cons(next), FP.Nil, arr)
	
	static func is_of_type(other_type: TYPE) -> Callable:
		return FP.is_of_type(TYPE.LIST)
	
	static func of(val: Variant = null) -> List:
		return List.new(val, FP.Nil)

	static func point(val: Variant = null) -> List:
		return List.new(val, FP.Nil)

	static func pure(val: Variant = null) -> List:
		return List.new(val, FP.Nil)

	static func unit(val: Variant = null) -> List:
		return List.new(val, FP.Nil)

	func _init(val: Variant = null, l: List = null) -> void:
		_max_id += 1
		id = _max_id
		if !val and !l:
			is_Nil = true
			size_ = 0
		else:
			is_Nil = false
			head_ = val
			tail_ = l if l else FP.Nil
			size_ = tail_.size() + 1

	func ap(list: Variant = null) -> List:
		return __utils__.list_ap(self, list)

	func ap_to(list_with_values: Variant = null) -> List:
		return __utils__.list_ap(self, list_with_values)

	func append(list: Variant = null) -> List:
		return __utils__.append(self, list)

	func bind(f: Callable = Callable()) -> Variant:
		return map(f).flatten()

	func chain(f: Callable = Callable()) -> Variant:
		return map(f).flatten()

	func concat(list: Variant = null) -> List:
		return __utils__.append(self, list)

	func cons(head: Variant = null) -> List:
		return FP.List_(head, self)

	func contains(val: Variant = null) -> bool:
		return __utils__.list_contains(self, val)

	func equals(other: Variant = null) -> bool:
		return (__utils__.List_is_of_type(other) or __utils__.NEL_is_of_type(other) and __utils__.list_equals(self, other))

	func every(f: Callable = Callable()) -> bool:
		return to_Array().all(f)

	func exists(f: Callable = Callable()) -> bool:
		return to_Array().any(f)

	func filter(f: Callable = Callable()) -> List:
		return __utils__.list_filter(self, f)

	func filter_not(f: Callable = Callable()) -> List:
		return filter(func(a) -> bool: return !f.call(a))

	func find(f: Callable = Callable()) -> Variant:
		return __utils__.list_find(self, f)

	func flat_map(f: Callable = Callable()) -> Variant:
		return map(f).flatten()

	func flatten() -> Variant:
		return __utils__.list_fold_right(FP.append, self, FP.Nil)

	func flatten_Maybe() -> Variant:
		return flat_map(FP.Maybe_to_list)

	func fold_left(initial_val: Variant = null) -> Variant:
		var this = self
		return func (f: Callable = Callable()) -> Variant: return __utils__.list_fold_left(f, initial_val, this)

	func fold_right(initial_val: Variant = null) -> Variant:
		var this = self
		return func (f: Callable = Callable()) -> Variant: return __utils__.list_fold_right(f, this, initial_val)

	func for_all(f: Callable = Callable()) -> bool:
		return to_Array().all(f)

	func for_each(f: Callable = Callable()) -> Variant:
		return __utils__.list_for_each(f, self)

	func head() -> Variant:
		return head_

	func head_maybe() -> Maybe:
		return FP.Nothing() if is_Nil else FP.Just(head_)

	func inspect() -> String:
		return to_String()

	func is_NEL() -> bool:
		return false

	func join() -> Variant:
		return flat_map(FP.id_function)

	func lookup(i: int = 0) -> Maybe:
		return FP.Nothing() if is_Nil or i >= size() else FP.Maybe_from_null(to_Array()[i])

	func map(f: Callable = Callable()) -> Variant:
		return __utils__.list_map(f, self)

	func nth(i: int = 0) -> Maybe:
		return null if is_Nil or i >= size() else to_Array()[i]

	func reverse() -> List:
		return __utils__.list_reverse(self)

	func sequence(monad_type: TYPE = TYPE.MAYBE) -> Variant:
		return __utils__.sequence(self, monad_type)

	func sequence_Either() -> Variant:
		return __utils__.sequence(self, TYPE.EITHER)

	func sequence_IO() -> Variant:
		return __utils__.sequence(self, TYPE.IO)

	func sequence_Maybe() -> Variant:
		return __utils__.sequence(self, TYPE.MAYBE)

	func sequence_Reader() -> Variant:
		return __utils__.sequence(self, TYPE.READER)

	func sequence_Validation() -> Variant:
		return __utils__.sequence_validation(self)

	func size() -> int:
		return size_

	func snoc(element: Variant = null) -> List:
		return concat(FP.List.new(element))

	func tail() -> List:
		return FP.Nil if is_Nil else tail_

	func tails() -> List:
		return FP.List.new(FP.Nil, FP.Nil) if is_Nil else tail().tails().cons(self)

	func take_left(m: Variant = null) -> Variant:
		return FP.apply2(self, m, FP.Y.K)

	func take_right(m: Variant = null) -> Variant:
		return FP.apply2(self, m, FP.Y.KI)

	func to(functor: Variant = null) -> Variant:
		return functor.new(self)

	func to_Array() -> Array:
		return __utils__.list_fold_left(func(acc: Array, e): acc.append(e);return acc, [], self)

	func to_String() -> String:
		return "Nil" if is_Nil else "List(" + FP.Arr.join(to_Array())+")"

class Maybe:

	const TYPE_KEY: TYPE = TYPE.MAYBE

	static var _max_id	: int = 0
	var id				: int
	var val				: Variant
	var is_value		: bool

	static func of(a: Variant = null) -> Maybe:
		return FP.Just(a)

	static func from_empty(val: Variant = null) -> Maybe:
		return FP.Nothing() if FP.is_empty(val) else FP.Just(val)
		
	static func from_falsy(val: Variant = null) -> Maybe:
		return FP.Nothing() if !val else FP.Just(val)
		
	static func from_null(val: Variant = null) -> Maybe:
		return FP.Nothing() if FP.is_nothing(val) else FP.Just(val)
	
	static func is_of_type(other_type: TYPE) -> Callable:
		return FP.is_of_type(TYPE.MAYBE)
	
	static func point(a: Variant = null) -> Maybe:
		return FP.Just(a)

	static func pure(a: Variant = null) -> Maybe:
		return FP.Just(a)

	static func to_list(m: Maybe = FP.Nothing()) -> List:
		return m.to_list()

	static func unit(a: Variant = null) -> Maybe:
		return FP.Just(a)
		
	func _init(is_value_: bool = false, val_: Variant = null) -> void:
		_max_id += 1
		id = _max_id
		is_value = is_value_
		if is_value and FP.is_nothing(val): push_error("Can not create Just with illegal value: " + val + ".")
		val = val_

	# NOT FINISHED !!!!! TEMPORARY

	func ap(maybe_with_f: Maybe = null) -> Variant:
		var value: Variant = val
		return maybe_with_f.map(func(f: Callable = Callable()) -> Variant: return f.call(value)) if is_value else self

	func ap_to(maybe_with_val: Maybe = null) -> Variant:
		return maybe_with_val.ap(self)

	func bind(bind_f: Callable = Callable()) -> Variant:
		return bind_f.call(val) if is_value else self

	func cata(nothing: Callable = Callable(), just: Callable = Callable()) -> Variant:
		return just.call(val) if is_Just() else nothing.call()

	func catch_map(f: Callable = Callable()) -> Variant:
		return self if is_Just() else f.call()

	func chain(bind_f: Callable = Callable()) -> Variant:
		return bind_f.call(val) if is_value else self

	func contains(val_: Variant = null) -> bool:
		return FP.are_equal(val, val_) if is_Just() else false

	func equals(other: Variant = null) -> bool:
		return __utils__.Maybe_is_of_type(other) and cata(
			func() -> bool: return other.is_none(),
			func(val: Variant = null) -> Variant: return other.fold(false).call(equals(val)))

	func every(f: Callable = Callable()) -> bool:
		return to_Array().all(f)

	func exists(f: Callable = Callable()) -> bool:
		return to_Array().any(f)

	func filter(f: Callable = Callable()) -> Variant:
		var this = self
		return flat_map(func(a: Variant = null) -> Variant: return this if f.call(a) else FP.Nothing())

	func filter_not(f: Callable = Callable()) -> List:
		return filter(func(a) -> bool: return !f.call(a))

	func flat_map(bind_f: Callable = Callable()) -> Variant:
		return bind_f.call(val) if is_value else self

	func fold(initial_value: Variant = null) -> Variant:
		var this = self
		return func(f: Callable = Callable()) -> Variant: return f.call(this.val) if this.is_Just() else initial_value

	func fold_left(initial_value: Variant = null) -> Variant:
		return to_List().fold_left(initial_value)

	func fold_right(initial_value: Variant = null) -> Variant:
		return to_List().fold_right(initial_value)

	func for_each(f: Callable = Callable()) -> Variant:
		return cata(FP.noop, f)

	func get_or_else() -> Variant:
		return is_value

	func inspect() -> String:
		return to_String()

	func is_Just() -> Variant:
		return is_value

	func is_None() -> Variant:
		return !is_Some()

	func is_Nothing() -> Variant:
		return !is_Just()

	func is_Some() -> Variant:
		return is_value

	func join() -> Variant:
		return flat_map(FP.id_function)

	func just() -> Variant:
		if is_value: return val
		else: push_error("Can not call .just() on Nothing.");return

	func map(f: Callable = Callable()) -> Variant:
		return flat_map(FP.compose2(of, f))

	func or_else(m: Maybe = null) -> Variant:
		return catch_map(func() -> Maybe: return m)

	func or_else_run(f: Callable = Callable()) -> Variant:
		return cata(f, FP.noop)

	func or_Just(other_value: Variant = null) -> Variant:
		return val if is_value else other_value

	func or_lazy(get_other_value: Variant = null) -> Variant:
		return cata(get_other_value, FP.id_function())

	func or_None_if(b: bool = false) -> Maybe:
		return FP.Nothing() if b else self

	func or_Nothing_if(b: bool = false) -> Maybe:
		return FP.Nothing() if b else self

	func or_null() -> Variant:
		return or_Some(null)

	func or_Some(other_value: Variant = null) -> Variant:
		return val if is_value else other_value

	func some() -> Variant:
		if is_value: return val
		else: push_error("Can not call .some() on None.");return

	func take_left(m: Variant = null) -> Variant:
		return FP.apply2(self, m, FP.Y.K)

	func take_right(m: Variant = null) -> Variant:
		return FP.apply2(self, m, FP.Y.KI)

	func to(functor: Variant = null) -> Variant:
		return functor.new(self)

	func to_Array() -> Array:
		return map(func(val: Variant = null) -> Array: return [val]).or_lazy(func() -> Array: return [])

	func to_Either(fail_value: Variant = null) -> Either:
		return FP.Right(val) if is_Just() else FP.Left(fail_value)

	func to_List() -> List:
		return map(FP.List_).or_lazy(func() -> List: return FP.Nil)

	func to_String() -> String:
		return "Just("+val+")" if is_Just() else "Nothing"

	func to_Validation(fail_value: Variant = null) -> Validation:
		return FP.Success(val) if is_Just() else FP.Fail(fail_value)

class MonadT:

	const TYPE_KEY: TYPE = TYPE.MONADT

	static var _max_id	: int = 0
	var id				: int
	var monad			: Variant
	
	static func is_of_type(other_type: TYPE) -> Callable:
		return FP.is_of_type(TYPE.MONADT)

	static func of(monad: Variant = null) -> MonadT:
		return MonadT.new(monad)

	static func point(monad: Variant = null) -> MonadT:
		return MonadT.new(monad)

	static func pure(monad: Variant = null) -> MonadT:
		return MonadT.new(monad)

	static func unit(monad: Variant = null) -> MonadT:
		return MonadT.new(monad)

	func _init(m: Variant = null) -> void:
		_max_id += 1
		id = _max_id
		monad = m
	
	func ap(monad_with_f: Variant = null) -> MonadT: 
		return MonadT.new(monad.flat_map(func(v: Variant = null) -> Variant:
			return monad_with_f.perform().map(func(v2: Variant = null) -> Variant:
				return v.ap(v2))))

	func bind(f: Callable = Callable()) -> MonadT: 
		return MonadT.new(monad.map(func(v: Variant = null) -> Variant: return v.flat_map(f)))

	func chain(f: Callable = Callable()) -> MonadT: 
		return MonadT.new(monad.map(func(v: Variant = null) -> Variant: return v.flat_map(f)))
			
	func flat_map(f: Callable = Callable()) -> MonadT: 
		return MonadT.new(monad.map(func(v: Variant = null) -> Variant: return v.flat_map(f)))
			
	func join() -> Variant:
		return flat_map(FP.id_function)
	
	func map(f: Callable = Callable()) -> MonadT: 
		return MonadT.new(monad.map(func(v: Variant = null) -> Variant: return v.map(f)))

	func perform():
		return monad

	func take_left(m: Variant = null) -> Variant:
		return FP.apply2(self, m, FP.Y.K)

	func take_right(m: Variant = null) -> Variant:
		return FP.apply2(self, m, FP.Y.KI)

class NEL:

	const TYPE_KEY: TYPE = TYPE.NEL

	static var _max_id	: int = 0
	var id 				: int
	var is_Nil			: bool
	var head_			: Variant
	var tail_			: List
	var size_			: int

	static func from_array(arr: Array = []) -> Maybe:
		return NEL.from_list(List.from_array(arr))

	static func from_list(list: List = FP.Nil) -> Maybe:
		return FP.Nothing() if list.is_nil else FP.Just(NEL.new(list.head(), list.tail()))

	static func of(val: Variant = null) -> NEL:
		return NEL.new(val, FP.Nil)

	static func point(val: Variant = null) -> NEL:
		return NEL.new(val, FP.Nil)

	static func pure(val: Variant = null) -> NEL:
		return NEL.new(val, FP.Nil)

	static func unit(val: Variant = null) -> NEL:
		return NEL.new(val, FP.Nil)


	func _init(head: Variant = null, tail: Variant = null) -> void:
		_max_id += 1
		id = _max_id
		if FP.is_nothing(head): push_error("Can't create empty Non-Empty List. Passed head is " + head + ".")
		else:
			is_Nil = false
			head_ = head
			tail_ = FP.Nil if FP.is_nothing(tail) else tail
			size_ = tail_.size() + 1


	func ap(list: Variant = null) -> NEL:
		return __utils__.list_ap(self, list)

	func ap_to(list_with_values: NEL = null) -> Variant:
		return __utils__.list_ap(self, list_with_values)

	func append(list: Variant = null) -> NEL:
		return NEL.from_list(to_List().appent(list.to_List)).just()

	func bind(f: Callable = Callable()) -> Variant:
		var p: Variant = f.call(head())
		if !p.is_NEL(): push_error("NEL.bind: Passed function must return a NonEmptyList.")
		var list = tail().fold_left(FP.Nil.snoc(p.head())).append(p.tail()).call(func(acc: Variant, e: Variant = null) -> List:
			var list2 = f.call(e).to_List()
			return acc.snoc(list2.head()).append(list2.tail()))
		return NEL.new(list.head(), list.tail())

	func chain(f: Callable = Callable()) -> Variant:
		return bind(f)

	func cobind(f: Callable = Callable()) -> Variant:
		return cojoin().map(f)

	func coflat_map(f: Callable = Callable()) -> Variant:
		return cojoin().map(f)

	func cojoin() -> NEL:
		return tails()

	func concat(list: Variant = null) -> NEL:
		return NEL.from_list(to_List().appent(list.to_List)).just()

	func cons(head: Variant = null) -> void:
		return FP.NEL_(head, to_List())

	func contains(val: Variant = null) -> bool:
		return __utils__.list_contains(to_List(), val)

	func copure() -> Variant:
		return head_

	func equals(other: Variant = null) -> bool:
		return (__utils__.List_is_of_type(other) or __utils__.NEL_is_of_type(other) and __utils__.list_equals(self, other))

	func every(f: Callable = Callable()) -> bool:
		return to_Array().all(f)

	func exists(f: Callable = Callable()) -> bool:
		return to_Array().any(f)

	func extract() -> Variant:
		return head_

	func filter(f: Callable = Callable()) -> NEL:
		return __utils__.list_filter(to_List(), f)

	func filter_not(f: Callable = Callable()) -> NEL:
		return filter(func(a) -> bool: return !f.call(a))

	func find(f: Callable = Callable()) -> Variant:
		return __utils__.list_find(to_List(), f)

	func flat_map(f: Callable = Callable()) -> Variant:
		return bind(f)

	func flatten() -> Variant:
		return __utils__.list_fold_right(append, to_List().map(func(list: Variant = null) -> Variant:
			return list.to_List() if list.is_NEL() else list), FP.Nil)

	func flatten_Maybe() -> Variant:
		return self.to_List().flat_map(FP.Maybe_to_list)

	func fold_left(initial_val: Variant = null) -> Variant:
		return func (f: Callable = Callable()) -> Variant: return to_List().fold_left(initial_val)

	func fold_right(initial_val: Variant = null) -> Variant:
		return func (f: Callable = Callable()) -> Variant: return to_List().fold_left(initial_val)

	func for_all(f: Callable = Callable()) -> bool:
		return to_Array().all(f)

	func for_each(f: Callable = Callable()) -> Variant:
		return to_List().for_each(f)

	func head() -> Variant:
		return head_

	func head_maybe() -> Maybe:
		return FP.Nothing() if is_Nil else FP.Just(head_)

	func inspect() -> String:
		return to_String()

	func is_NEL() -> bool:
		return true

	func join() -> Variant:
		return flat_map(FP.id_function)

	func lookup(i: int = 0) -> Maybe:
		return FP.Nothing() if i >= size() else FP.Maybe_from_null(to_Array()[i])

	func map(f: Callable = Callable()) -> Variant:
		return FP.NEL.new(f.call(head_), __.__utils__list_map(f, tail_))

	func map_tails(f: Callable = Callable()) -> Variant:
		return cojoin().map(f)

	func nth(i: int = 0) -> Maybe:
		return null if i >= size() else to_Array()[i]

	func reverse() -> NEL:
		if tail().is_Nil: return self
		var reversed_tail: NEL = tail().reverse()
		return NEL.new(reversed_tail.head(), reversed_tail.tail().append(List.new(head())))

	func reduce_left(f: Callable = Callable()) -> Variant:
		return tail().fold_left(head()).call(f)

	func size() -> int:
		return size_

	func tail() -> Variant:
		return tail_

	func tails() -> NEL:
		var list_of_NELs = to_List().tails().map(FP.NEL_from_list).flatten_maybe()
		return NEL.new(list_of_NELs.head(), list_of_NELs.tail())

	func take_left(m: Variant = null) -> Variant:
		return FP.apply2(self, m, FP.Y.K)

	func take_right(m: Variant = null) -> Variant:
		return FP.apply2(self, m, FP.Y.KI)

	func to(functor: Variant = null) -> Variant:
		return functor.new(self)

	func to_List() -> List:
		return List.new(head_, tail_)

	func to_Array() -> Array:
		return __utils__.list_fold_left(func(acc: Array, e): acc.append(e);return acc, [], self)

	func to_String() -> String:
		return "Nil" if is_Nil else "NEL(" + FP.Arr.join(to_Array())+")"

	func snoc(element: Variant = null) -> NEL:
		return concat(FP.NEL.new(element))

class Reader:

	const TYPE_KEY: TYPE = TYPE.READER

	static var _max_id	: int = 0
	var id				: int
	var f				: Callable
	
	static func is_of_type(other_type: TYPE) -> Callable:
		return FP.is_of_type(TYPE.READER)

	static func of(a: Variant = null) -> Reader:
		return Reader.new(func(b: Variant = null) -> Variant: return a)

	static func point(a: Variant = null) -> Reader:
		return Reader.new(func(b: Variant = null) -> Variant: return a)
	
	static func pure(a: Variant = null) -> Reader:
		return Reader.new(func(b: Variant = null) -> Variant: return a)

	static func ask() -> Reader:
		return Reader.new(FP.id_function)

	static func unit(a: Variant = null) -> Reader:
		return Reader.new(func(b: Variant = null) -> Variant: return a)
	
	func _init(f_: Callable = Callable()) -> void:
		_max_id += 1
		id = _max_id
		f = f_
	
	func ap(reader_with_f: Reader = null) -> Reader:
		var this = self
		return reader_with_f.bind(func(f_:Callable = Callable()) -> Reader: 
			return Reader.new(func(config: Variant = null) -> Variant: 
				return f_.call(this.run(config))))
		
	func ap_to(reader_with_value: Reader = null) -> Reader:
		return reader_with_value.ap(self)
		
	func bind(f_:Callable = Callable()) -> Reader:
		var this = self
		return Reader.new(func(config) -> Variant: 
			return f_.call(this.run(config)).run(config))
		
	func chain(f_:Callable = Callable()) -> Reader:
		var this = self
		return Reader.new(func(config) -> Variant: 
			return f_.call(this.run(config)).run(config))
		
	func flat_map(f_:Callable = Callable()) -> Reader:
		var this = self
		return Reader.new(func(config) -> Variant: 
			return f_.call(this.run(config)).run(config))

	func join() -> Variant:
		return flat_map(FP.id_function)

	func local(f_:Callable = Callable()) -> Reader:
		var this = self
		return Reader.new(func(config: Variant = null) -> Variant: 
			return this.run(f_.call(config)))
 
	func map(f_:Callable = Callable()) -> Reader:
		var this = self
		return Reader.new(func(config: Variant = null) -> Variant: 
			return f_.call(this.run(config)))
		
	func run(config: Variant = null) -> Variant: 
		return f.call(config)

	func take_left(m: Variant = null) -> Variant:
		return FP.apply2(self, m, FP.Y.K)
	
	func take_right(m: Variant = null) -> Variant:
		return FP.apply2(self, m, FP.Y.KI)
			
class Validation:

	const TYPE_KEY: TYPE = TYPE.VALIDATION

	static var _max_id		: int = 0
	var id					: int
	var val					: Variant
	var is_success_value	: bool

	static func Fail(err: Variant = null) -> Validation:
		return Validation.new(err, false)
	
	static func is_of_type(other_type: TYPE) -> Callable:
		return FP.is_of_type(TYPE.VALIDATION)
	
	static func of(v: Variant = null) -> Validation:
		return FP.Success(v)
	
	static func point(v: Variant = null) -> Validation:
		return FP.Success(v)
	
	static func pure(v: Variant = null) -> Validation:
		return FP.Success(v)

	static func Success(val: Variant = null) -> Validation:
		return Validation.new(val, true)

	static func unit(v: Variant = null) -> Validation:
		return FP.Success(v)

	func _init(val_: Variant = null, success: bool = false) -> void:
		_max_id += 1
		id = _max_id
		val = val_
		is_success_value = success

	func acc():
		var x: Callable
		x = func(): return x
		return FP.Validation_Success(x) if is_success_value else self
	
	func ap(validation_with_f: Validation = null) -> Variant: 
		var value = val
		if is_Success():
			return validation_with_f.map(func(f): return f.call(value))
		elif validation_with_f.isFail():
			return FP.Validation_Fail(FP.Semigroup_append(value, validation_with_f.fail()))
		else: return self
	
	func ap_to(validation_with_value: Validation = null) -> Variant:
		return validation_with_value.ap(self)

	func bind(f: Callable = Callable()) -> Variant:
		return f.call(val) if is_Success() else self

	func bimap(fail: Callable = Callable(), success: Callable = Callable()) -> Variant: 
		return map(success) if is_success_value else fail_map(fail)
	
	func cata(fail: Callable = Callable(), success: Callable = Callable()) -> Variant: 
		return success.call(val) if is_success_value else fail.call(val)
	
	func catch_map(f: Callable = Callable()) -> Variant: 
		return self if is_Success() else f.call(val)
		
	func chain(f: Callable = Callable()) -> Variant:
		return f.call(val) if is_Success() else self

	func equals(other: Variant = null) -> bool: 
		return Validation.is_of_type(other) and cata(
			func(fail): return other.cata(equals(fail), FP.false_function), 
			func(success): return other.cata(FP.false_function, equals(success)))

	func fail() -> Variant: 
		if is_Success():
			push_error("Cannot call fail() on Success.")
		return val

	func fail_map(f: Callable = Callable()) -> Validation: 
		return FP.Fail(f.call(val)) if is_Fail() else self
	
	func flat_map(f: Callable = Callable()) -> Variant:
		return f.call(val) if is_Success() else self

	func fold(fail: Callable = Callable(), success: Callable = Callable()) -> Variant: 
		return success.call(val) if is_success_value else fail.call(val)
	
	func fold_left(initial_value: Variant = null) -> Variant: 
		return to_Maybe().to_List().fold_left(initial_value)
	
	func fold_right(initial_value: Variant = null) -> Variant: 
		return to_Maybe().to_List().fold_right(initial_value)

	func for_each(f: Callable = Callable()) -> Variant: 
		return cata(FP.noop, f)
	
	func for_each_fail(f: Callable = Callable()) -> Variant: 
		return cata(f, FP.noop)

	func inspect() -> String: 
		return to_string()
		
	func is_Success() -> bool:
		return is_success_value

	func is_Fail() -> bool:
		return !is_success_value

	func join() -> Variant:
		return flat_map(FP.id_function)

	func map(f: Callable = Callable()) -> Variant:
		return flat_map(FP.compose2(of, f))

	func success() -> Variant: 
		if is_Success(): 
			return val
		push_error("Cannot call success() on Fail."); return
			
	func swap() -> Validation: 
		return FP.Fail(val) if is_Success() else FP.Success(val)

	func take_left(m: Variant = null) -> Variant:
		return FP.apply2(self, m, FP.Y.K)
	
	func take_right(m: Variant = null) -> Variant:
		return FP.apply2(self, m, FP.Y.KI)
			
	func to_Either() -> Either: 
		return (FP.Right if is_Success() else FP.Left).call(val)
	
	func to_Maybe() -> Maybe: 
		return FP.Some(val) if is_Success() else FP.None()
	
	func to_String() -> String: 
		return ('Success(' if is_Success() else 'Fail(') + val + ')'
	
class Y:

	static func B(f: Callable = Callable()) -> Callable:
		return func(g: Callable = Callable()) -> Callable:
			return func(a: Variant = null) -> Variant:
				return f.call(g.call(a))

	static func BL(f: Callable = Callable()) -> Callable:
		return func(g: Callable = Callable()) -> Callable:
			return func(a: Variant = null, b: Variant = null) -> Variant:
				if !b or b == null: return func(b: Variant = null) -> Variant: return f.call(g.call(a).call(b))
				return f.call(g.call(a, b))

	static func C(f: Callable = Callable()) -> Callable:
		return func(a: Variant = null, b: Variant = null) -> Callable:
			if !b or b == null: return func(b: Variant = null) -> Variant: return f.call(b).call(a)
			else: return f.call(b, a)

	static func I(a: Variant = null) -> Variant:
		return a

	static func K(a: Variant = null) -> Callable:
		return func(b: Variant = null) -> Variant: return a

	static func KI(a: Variant = null) -> Callable:
		return func(b: Variant = null) -> Variant: return b

	static func M(f: Callable = Callable()) -> Variant:
		return f.call(f)

	static func TH(a: Variant = null, f: Callable = Callable()) -> Variant:
		return f.call(a)

	static func V(a: Variant = null, b: Variant = null) -> Callable:
		if !b or b == null: return func(b: Variant = null) -> Callable:
			return func(f: Callable = Callable()) -> Variant: return f.call(a).call(b)
		else: return func(f: Callable = Callable()) -> Variant: return f.call(a, b)

#???
class Tuple:

	static func fst(f: Callable = Callable()) -> Variant:
		return f.call(Y.K)

	static func t2(a: Variant = null, b: Variant = null) -> Callable:
		return Y.V(a) if !b or b == null else Y.V(a, b)

	static func snd(f: Callable = Callable()) -> Variant:
		return f.call(Y.KI)
