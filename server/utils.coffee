module.exports =

  # Test for integer-ness
  isInteger: (putativeInteger) ->
    putativeInteger is +putativeInteger and putativeInteger is (putativeInteger|0)
