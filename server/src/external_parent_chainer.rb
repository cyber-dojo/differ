
module ExternalParentChainer # mix-in

  def method_missing(command, *args)
    current = self
    loop { current = current.parent }
  rescue NoMethodError
    raise "not-expecting-arguments #{args}" if args != []
    current.send(command, *args)
  end

end

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Provides transparent access to the external objects held in the root object:
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Works by assuming the object (which included this module) has a parent
# property and repeatedly chains back parent to parent to parent
# till it gets to an object without a parent property which it assumes
# is the root object, which it delegates to.
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
