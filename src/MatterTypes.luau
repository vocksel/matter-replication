export type Component<T> = (initialData: T?) -> ComponentInstance<T>

-- TODO: Add below metatable to this when it works better
export type ComponentInstance<T> = T

-- FUTURE: Improve above type and add this patch method when
-- typeof(setmetatable()) works better with generic args,
-- right now a recursive type such as this also seems
-- to break a lot of tooling such as luau-lsp
type ComponentInstanceMeta<T> = {
	patch: (self: ComponentInstance<T>, changes: T) -> ComponentInstance<T>,
}

type SystemFn = (...any) -> ()

type SystemTable = {
	system: SystemFn,
	event: string?,
	priority: number?,
	after: { System }?,
}

export type System = SystemFn | SystemTable

type WorldChangeRecord<T> = {
	old: ComponentInstance<T>?,
	new: ComponentInstance<T>?,
}

type WorldGetOrRemove =
	(<T>(self: World, id: number, Component<T>) -> ComponentInstance<T>)
	& (<T, U>(
		self: World,
		id: number,
		Component<T>,
		Component<U>
	) -> (ComponentInstance<T>, ComponentInstance<U>))
	& (<T, U, V>(
		self: World,
		id: number,
		Component<T>,
		Component<U>,
		Component<V>,
		...any
	) -> (ComponentInstance<T>, ComponentInstance<U>, ComponentInstance<V>))

-- FUTURE: This is missing query modifiers such as :without()
-- but there is currently no way to properly make a type with
-- a metatable and generics and maintain proper type inference
type WorldQueryResult<T...> = () -> (number, T...)

-- TODO: Use this type instead of the above
-- type when it works with type inference
--[[
type WorldQueryResult<T...> = typeof(setmetatable(
	{},
	{} :: {
		__iter: (self: WorldQueryResult<T...>) -> (() -> (number, T...)),
		__index: {
			without: (self: WorldQueryResult<T...>, ...any) -> WorldQueryResult<T...>,
			snapshot: (self: WorldQueryResult<T...>) -> WorldQueryResult<T...>,
			next: (self: WorldQueryResult<T...>) -> (number, T...),
		},
	}
))
]]

-- NOTE: We don't use more than 4 generics here since that
-- seems to currently lead to some performance issues
type WorldQuery =
	(<T>(self: World, Component<T>) -> WorldQueryResult<ComponentInstance<T>>)
	& (<T, U>(
		self: World,
		Component<T>,
		Component<U>
	) -> WorldQueryResult<ComponentInstance<T>, ComponentInstance<U>>)
	& (<T, U, V>(
		self: World,
		Component<T>,
		Component<U>,
		Component<V>
	) -> WorldQueryResult<ComponentInstance<T>, ComponentInstance<U>, ComponentInstance<V>>)
	& (<T, U, V, W>(
		self: World,
		Component<T>,
		Component<U>,
		Component<V>,
		Component<W>,
		...any
	) -> WorldQueryResult<ComponentInstance<T>, ComponentInstance<U>, ComponentInstance<V>, ComponentInstance<W>>)

type WorldQueryChanged = <T>(self: World, Component<T>) -> () -> (number, WorldChangeRecord<T>)

export type World = typeof(setmetatable(
	{},
	{} :: {
		__iter: (self: World) -> (() -> (number, { [any]: ComponentInstance<any> }), any),
		__index: {
			clear: (self: World) -> (),
			contains: (self: World, id: number) -> boolean,
			despawn: (self: World, id: number) -> (),
			get: WorldGetOrRemove,
			insert: (self: World, id: number, ...ComponentInstance<any>) -> (),
			optimizeQueries: (self: World) -> (),
			query: WorldQuery,
			queryChanged: WorldQueryChanged,
			remove: WorldGetOrRemove,
			replace: (self: World, id: number, ...ComponentInstance<any>) -> (),
			size: (self: World) -> number,
			spawn: (self: World, ...ComponentInstance<any>) -> number,
			spawnAt: (self: World, id: number, ...ComponentInstance<any>) -> number,
			new: () -> World,
		},
	}
))

return nil
