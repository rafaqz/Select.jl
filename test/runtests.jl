using Revise, Select, Test, FieldDefaults

import Select: selectable, @selectable, flattenable, @flattenable

@default_kw struct SubTest{X,Y}
    x::X | 1.0
    y::Y | :default
end

@selectable @flattenable @default_kw struct TestStruct{A,B,C,D}
    a::A | SubTest() | true  | Union{Nothing,SubTest}
    b::B | _         | true  | _
    c::C | SubTest() | true  | Union{Nothing,SubTest}
    d::D | SubTest() | false | _
end

t = TestStruct(1.0, 2, SubTest(8.0, 9.0), :nochange)
@test select(t) == ((Union{Nothing,SubTest}, Float64, :a), (Union{Nothing,SubTest}, SubTest, :c))

@test updateselected(t, (Nothing, Nothing,)) == 
    TestStruct{Nothing,Int64,Nothing,Symbol}(nothing, 2, nothing, :nochange)
@test updateselected(t, (Nothing, SubTest,)) == 
    TestStruct{Nothing,Int64,SubTest{Float64,Symbol},Symbol}(nothing, 2, SubTest(1.0, :default), :nochange)

t = TestStruct(SubTest(2,:update), 2, SubTest(2.0,:noupdate), :nochange)
@test updateselected(t, (SubTest, SubTest,)) ==
    TestStruct{SubTest{Float64,Symbol},Int64,SubTest{Float64,Symbol},Symbol}(SubTest(1.0, :default), 2, SubTest(2.0, :noupdate), :nochange)
