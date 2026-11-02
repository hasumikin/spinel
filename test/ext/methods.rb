# --ext-class fixture: a kernel whose objects a C host holds, and whose
# instance methods the host calls by name through the exported method
# table (methods_host.c): a method of the class, one it inherits, one it
# overrides with super, a String parameter and result, a nullable Integer
# result, a method answering an object, the attr readers and a writer, a
# singleton method, and a private method that the table leaves out.
module ExtMethods
  class Counter
    attr_reader :name, :n
    attr_accessor :tag

    def initialize(name)
      @name = name
      @n = 0
      @tag = ""
    end

    def bump(k)
      @n += k
    end

    def label(sep)
      name + sep + n.to_s
    end

    def half
      n.even? ? n / 2 : nil
    end

    def twin
      Counter.new(name + "2")
    end

    # a Hash parameter: a value of another kind is TypeError at the boundary
    def keys(h)
      h.keys.map(&:to_s).sort.join(",")
    end

    def self.opts
      { b: 1, a: 2 }
    end

    private def secret
      42
    end

    # a singleton method: called on the class value, inherited by Loud
    def self.zero
      Counter.new("zero")
    end
  end

  class Loud < Counter
    def shout
      name.upcase
    end

    def bump(k)
      super(k * 2)
    end
  end

  # the entries answer boxed objects, as a host holds them
  #: (String) -> untyped
  def self.make(name)
    Counter.new(name)
  end

  #: (String) -> untyped
  def self.loud(name)
    Loud.new(name)
  end
end

if __FILE__ == $0
  c = ExtMethods.make("c")
  c.bump(1)
  puts c.label(":")
  p c.half
  puts c.twin.name
  puts c.keys(ExtMethods::Counter.opts)
  l = ExtMethods.loud("l")
  l.bump(2)
  puts l.shout, l.n
end
