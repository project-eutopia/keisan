require "spec_helper"

RSpec.describe Keisan::Context do
  it "contains function and variable registries" do
    my_context = described_class.new

    my_context.register_variable!("x", 2)
    my_context.register_function!("f", Proc.new {|x| x**2})
    expect(my_context.variable("x").value).to eq 2
    expect(my_context.function("f").call(nil, 3).value).to eq 9
  end

  it "has default variables and functions" do
    my_context = described_class.new

    expect(my_context.variable("PI").value).to eq Math::PI
    expect(my_context.function("sin")).to be_a(Keisan::Function)
  end

  describe "freeze" do
    it "freezes associated registries" do
      frozen_context = described_class.new
      frozen_context.register_variable!("x", 1)
      frozen_context.register_function!("f", Proc.new {|x| x})
      frozen_context.freeze

      expect{frozen_context.register_variable!("x", 10)}.to raise_error(Keisan::Exceptions::UnmodifiableError)
      expect{frozen_context.register_function!("f", Proc.new {|x| x**2})}.to raise_error(Keisan::Exceptions::UnmodifiableError)

      child_context = frozen_context.spawn_child
      child_context.register_variable!("x", 2)
      child_context.register_function!("f", Proc.new {|x| 2*x})

      expect(frozen_context.variable("x").value).to eq 1
      expect(child_context.variable("x").value).to eq 2

      expect(frozen_context.function("f").call(nil, 3).value).to eq 3
      expect(child_context.function("f").call(nil, 3).value).to eq 6
    end

    it "works on list/hash variables" do
      calculator = Keisan::Calculator.new
      calculator.evaluate("x = [1, [2,3], {'a': 10, 'b': 20}]")
      calculator.evaluate("y = {'alpha': 6, 'beta': [7,7,7], 'gamma': {'foo': 100}}")

      # Can modify list no problem
      calculator.evaluate("x[0] += 10")
      calculator.evaluate("x[1][0] += 10")
      calculator.evaluate("x[2]['a'] += 10")
      expect(calculator.evaluate("x")).to eq([11, [12,3], {"a" => 20, "b" => 20}])

      # Can modify hash no problem
      calculator.evaluate("y['alpha'] += 10")
      calculator.evaluate("y['beta'][0] += 10")
      calculator.evaluate("y['gamma']['foo'] += 10")
      expect(calculator.evaluate("y")).to eq({"alpha" => 16, "beta" => [17,7,7], "gamma" => {"foo" => 110}})

      # Freeze
      calculator.context.freeze

      # Can still access the values
      expect(calculator.evaluate("x[0]")).to eq(11)
      expect(calculator.evaluate("y['alpha'] + 2")).to eq(18)

      child_calculator = Keisan::Calculator.new(context: calculator.context.spawn_child)
      child_calculator.evaluate("z = y['gamma']['foo'] * 3")
      expect(child_calculator.evaluate("z")).to eq(330)

      # But can no longer modify
      expect{calculator.evaluate("x[0] += 10")}.to raise_error(Keisan::Exceptions::UnmodifiableError)
      expect{calculator.evaluate("x[1][0] = 10")}.to raise_error(Keisan::Exceptions::UnmodifiableError)
      expect{calculator.evaluate("x[2]['a'] += 10")}.to raise_error(Keisan::Exceptions::UnmodifiableError)
      expect{calculator.evaluate("x = 10")}.to raise_error(Keisan::Exceptions::UnmodifiableError)

      expect{calculator.evaluate("y['alpha'] += 10")}.to raise_error(Keisan::Exceptions::UnmodifiableError)
      expect{calculator.evaluate("y['beta'][0] += 10")}.to raise_error(Keisan::Exceptions::UnmodifiableError)
      expect{calculator.evaluate("y['gamma']['foo'] += 10")}.to raise_error(Keisan::Exceptions::UnmodifiableError)
      expect{calculator.evaluate("y = 10")}.to raise_error(Keisan::Exceptions::UnmodifiableError)
    end
  end

  describe "spawn_child" do
    it "has parent context's variables and functions" do
      my_context = described_class.new

      my_context.register_variable!("x", 2)
      my_context.register_function!("f", Proc.new {|x| x**2})

      child_context = my_context.spawn_child
      expect(child_context.variable("x").value).to eq 2
      expect(child_context.function("f").call(nil, 3).value).to eq 9
    end

    it "can override parent with new definitions" do
      my_context = described_class.new

      my_context.register_variable!("x", 2)
      my_context.register_variable!("y", 7)
      my_context.register_function!("f", Proc.new {|x| x**2})
      my_context.register_function!("g", Proc.new {|x| x-1})

      child_context = my_context.spawn_child
      child_context.register_variable!("x", 5)
      child_context.register_variable!("z", 9)
      child_context.register_function!("f", Proc.new {|x| x**3})
      child_context.register_function!("h", Proc.new {|x| x**4})

      expect(my_context.variable("x").value).to eq 5 # Updated in child
      expect(my_context.variable("y").value).to eq 7
      expect{my_context.variable("z").value}.to raise_error(Keisan::Exceptions::UndefinedVariableError)
      expect(my_context.function("f").call(nil, 2).value).to eq 8 # Updated in child
      expect(my_context.function("g").call(nil, 2).value).to eq 1
      expect{my_context.function("h").value}.to raise_error(Keisan::Exceptions::UndefinedFunctionError)

      expect(child_context.variable("x").value).to eq 5
      expect(child_context.variable("y").value).to eq 7
      expect(child_context.variable("z").value).to eq 9
      expect(child_context.function("f").call(nil, 2).value).to eq 8
      expect(child_context.function("g").call(nil, 2).value).to eq 1
      expect(child_context.function("h").call(nil, 2).value).to eq 16
    end

    it "can hide parent variables with shadowed argument" do
      my_context = described_class.new

      my_context.register_variable!("x", 2)
      my_context.register_variable!("y", 7)

      child_context = my_context.spawn_child(shadowed: ["x"])

      expect(my_context.variable("x").value).to eq 2
      expect(my_context.variable("y").value).to eq 7
      expect{child_context.variable("x").value}.to raise_error(Keisan::Exceptions::UndefinedVariableError)
      expect(child_context.variable("y").value).to eq 7

      child_context.register_variable!("x", 13)
      expect(child_context.variable("x").value).to eq 13
    end
  end

  describe "random" do
    it "uses given Random object" do
      context1 = described_class.new(random: Random.new(1234))
      context2 = described_class.new(random: Random.new(1234))

      20.times do
        expect(context1.random.rand(100)).to eq context2.random.rand(100)
      end
    end

    it "uses parent random if does not have one" do
      rand1 = Random.new(2244)
      rand2 = Random.new(2244)

      parent = described_class.new(random: rand1)
      child  = described_class.new(parent: parent)

      20.times do
        expect(child.random.rand(100)).to eq rand2.rand(100)
      end
    end

    it "it shadows the parent random" do
      rand1 = Random.new(5151)
      rand1_copy = Random.new(5151)
      rand2 = Random.new(5959)

      parent = described_class.new(random: rand1)
      child  = described_class.new(parent: parent, random: rand2)

      matches = 20.times.map do |_|
        child.random.rand(100) == rand1_copy.rand(100)
      end

      expect(matches.any? {|bool| bool == false}).to be true
    end

    it "has the random object set once and only once" do
      context = described_class.new
      random = context.random
      expect(random).to eq context.random
    end

    it "can be set to override existing internal random object" do
      rand1 = Random.new(2244)
      rand1_copy = Random.new(2244)
      rand2 = Random.new(4466)

      context = described_class.new(random: rand2)
      context.set_random(rand1_copy)

      20.times do
        expect(context.random.rand(100)).to eq rand1.rand(100)
      end
    end
  end

  describe "has_variable?" do
    let(:context) { described_class.new }

    it "returns true of variable is defined" do
      expect(context.has_variable?("PI")).to eq true
      expect(context.has_variable?("not_exist")).to eq false
      context.register_variable!("not_exist", 5)
      expect(context.has_variable?("not_exist")).to eq true
    end
  end

  describe "has_function?" do
    let(:context) { described_class.new }

    it "returns true of function is defined" do
      expect(context.has_function?("sin")).to eq true
      expect(context.has_function?("not_exist")).to eq false
      context.register_function!("not_exist", Proc.new { nil })
      expect(context.has_function?("not_exist")).to eq true
    end
  end

  describe "transient context" do
    it "has parent context's variables and functions" do
      my_context = described_class.new

      my_context.register_variable!("x", 2)
      my_context.register_function!("f", Proc.new {|x| x**2})

      child_context = my_context.spawn_child(transient: true)
      expect(child_context.variable("x").value).to eq 2
      expect(child_context.function("f").call(nil, 3).value).to eq 9
    end

    it "can be overridden" do
      my_context = described_class.new

      my_context.register_variable!("x", 2)
      my_context.register_function!("f", Proc.new {|x| x**2})

      transient_context = my_context.spawn_child(transient: true)
      nontransient_context = transient_context.spawn_child(transient: false)

      transient_context.register_variable!("x", 3)
      expect(my_context.variable("x").value).to eq 3

      nontransient_context.register_variable!("x", 5)
      expect(my_context.variable("x").value).to eq 5 # Bubbled up
      expect(nontransient_context.variable("x").value).to eq 5
    end

    it "is transient so all definitions bubble up to parent context" do
      my_context = described_class.new

      my_context.register_variable!("x", 2)
      my_context.register_variable!("y", 7)
      my_context.register_function!("f", Proc.new {|x| x**2})
      my_context.register_function!("g", Proc.new {|x| x-1})

      expect(my_context.variable("x").value).to eq 2
      expect(my_context.variable("y").value).to eq 7
      expect(my_context.function("f").call(nil, 2).value).to eq 4
      expect(my_context.function("g").call(nil, 2).value).to eq 1

      child_context = my_context.spawn_child(transient: true)

      expect(my_context.transient?).to be false
      expect(child_context.transient?).to be true

      child_context.register_variable!("x", 5)
      child_context.register_function!("f", Proc.new {|x| x**3})
      Keisan::Calculator.new(context: child_context).evaluate("y = 11")
      Keisan::Calculator.new(context: child_context).evaluate("g(x) = 123*x")

      # Overriden by transient child!
      expect(my_context.variable("x").value).to eq 5
      expect(my_context.variable("y").value).to eq 11
      expect(my_context.function("f").call(nil, 2).value).to eq 8
      expect(my_context.function("g").call(nil, 2).value).to eq 246

      expect(child_context.variable("x").value).to eq 5
      expect(child_context.variable("y").value).to eq 11
      expect(child_context.function("f").call(nil, 2).value).to eq 8
      expect(child_context.function("g").call(nil, 2).value).to eq 246
    end

    it "stores transient definitions" do
      my_context     = described_class.new
      child_context  = my_context.spawn_child(definitions: {x: 15, f: Proc.new {|x| x**2}}, transient: true)
      child2_context = child_context.spawn_child(definitions: {y: 32, g: Proc.new {|x| x**3}}, transient: true)

      expect(child_context.transient_definitions.keys).to match_array(["x", "f"])
      expect(child2_context.transient_definitions.keys).to match_array(["x", "y", "f", "g"])
    end

    it "inherits transientness from parent" do
      my_context     = described_class.new
      child_context  = my_context.spawn_child(definitions: {x: 15, f: Proc.new {|x| x**2}}, transient: true)
      child2_context = child_context.spawn_child(definitions: {y: 32, g: Proc.new {|x| x**3}})

      expect(child_context.transient_definitions.keys).to match_array(["x", "f"])
      expect(child2_context.transient_definitions.keys).to match_array(["x", "y", "f", "g"])

      expect{my_context.variable("x")}.to raise_error(Keisan::Exceptions::UndefinedVariableError)
      child2_context.register_variable!("x", 123)
      expect(my_context.variable("x").value).to eq 123
    end
  end

  describe "local variables/functions" do
    context "variables" do
      it "does not bubble up to definition defined at parent context" do
        parent = described_class.new
        child  = parent.spawn_child(transient: false)

        parent.register_variable!("x", 1)
        child.register_variable!("x", 2)

        expect(parent.variable("x").value).to eq 2

        child.register_variable!("x", 3, local: true)

        expect(parent.variable("x").value).to eq 2
        expect(child.variable("x").value).to eq 3
      end
    end

    context "functions" do
      it "does not bubble up to definition defined at parent context" do
        parent = described_class.new
        child  = parent.spawn_child(transient: false)

        parent.register_function!("f", Proc.new {|x| 1})
        child.register_function!("f", Proc.new {|x| 2})

        expect(parent.function("f").call(nil, 100).value).to eq 2

        child.register_function!("f", Proc.new {|x| 3}, local: true)

        expect(parent.function("f").call(nil, 100).value).to eq 2
        expect(child.function("f").call(nil, 100).value).to eq 3
      end
    end
  end
end
