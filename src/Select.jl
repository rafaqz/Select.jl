module Select

using FieldMetadata

import FieldMetadata: flattenable, @flattenable, selectable, @selectable, default, label

export select, updateselected, selectable, @selectable

nested(T::Type, expr_builder, expr_combiner) = 
    expr_combiner(T, [Expr(:..., expr_builder(T, fn)) for fn in fieldnames(T)])

select_combiner(T, expressions) = Expr(:tuple, expressions...)
select_builder(T, fname) = quote
    selection = selectable($T, Val{$(QuoteNode(fname))})
    if selection != Nothing
        ((selection, typeof(t.$fname).name.wrapper, label($T, Val{$(QuoteNode(fname))})), )
    elseif flattenable($T, Val{$(QuoteNode(fname))})
        select(getfield(t, $(QuoteNode(fname))))
    else
        ()
    end
end
select_inner(T) = nested(T, select_builder, select_combiner)

@generated select(t) = select_inner(t)

updateselected_builder(T, fname) = quote
    selection = selectable($T, Val{$(QuoteNode(fname))})
    if selection != Nothing
        typ = data[n]
        n += 1
        # Only update if it's a different type
        if typ != fieldtype($T, $(QuoteNode(fname)))
            (typ(),)
        else
            (getfield(t, $(QuoteNode(fname))),)
        end
    elseif flattenable($T, Val{$(QuoteNode(fname))})
        val, n = updateselected(getfield(t, $(QuoteNode(fname))), data, n)
        val
    else
        (getfield(t, $(QuoteNode(fname))),)
    end
end

updateselected_combiner(T, expressions) = :(($(Expr(:call, :($T.name.wrapper), expressions...)),), n)
updateselected_combiner(T::Type{<:Tuple}, expressions) = :(($(Expr(:tuple, expressions...)),), n)

updateselected_inner(::Type{T}) where T = nested(T, updateselected_builder, updateselected_combiner)

updateselected(x::Number, data, n) = x, n
updateselected(x::Symbol, data, n) = x, n
updateselected(x::Nothing, data, n) = x, n
" Reconstruct an object from partial Tuple or Vector data and another object"
updateselected(t, data) = updateselected(t, data, 1)[1][1]
# Also increment vector position counter - the returned n + 1 becomes the new n
@generated updateselected(t, data, n) = updateselected_inner(t)

end # module
