using Select, Test, FieldDefaults

import Select: selectable, @selectable, flattenable, @flattenable

@default_kw struct SubTest{X,Y}
    x::X | 1.0
    y::Y | :test
end

@selectable @flattenable @default_kw struct TestStruct{A,B,C,D}
    a::A | SubTest() | true  | Union{Nothing,SubTest}
    b::B | _         | true  | _
    c::C | SubTest() | true  | Union{Nothing,SubTest}
    d::D | SubTest() | false | _
end

t = TestStruct(1.0, 2, SubTest(8.0,9.0), :empty)
s = Select.select_inner(typeof(t))
select(t)
defsubtest = SubTest()
@test select(t) == ((Union{Nothing,SubTest}, Float64, :a), (Union{Nothing,SubTest}, SubTest, :c))

s = Select.updateselected_inner(typeof(t))
@test updateselected(t, (Float64, Nothing,)) == TestStruct{Float64,Int64,Nothing,Symbol}(1.0, 2, nothing, :empty)
@test updateselected(t, (Float64, SubTest,)) == TestStruct{Float64,Int64,SubTest{Float64,Symbol},Symbol}(1.0, 2, SubTest(1.0, :test), :empty)
