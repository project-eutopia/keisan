require "spec_helper"

RSpec.describe "Turing machine" do
  let(:calculator) { Keisan::Calculator.new }

  before do
    calculator.evaluate(<<-KEISAN
                         tape_positive = [0]
                         tape_negative = []
                         tape_index(index) = if (index >= 0, index, index.abs() - 1)

                         tape_ensure_space(index) = {
                           if (index >= 0, {
                             while (index >= tape_positive.size, tape_positive = tape_positive + [0])
                             tape_positive[index]
                           }, {
                             let index = index.abs() - 1
                             while (index >= tape_negative.size, tape_negative = tape_negative + [0])
                             tape_negative[index]
                           })
                         }

                         tape_value(index) = {
                           tape_ensure_space(index)
                           if (index >= 0, {
                             tape_positive[tape_index(index)]
                           }, {
                             tape_negative[tape_index(index)]
                           })
                         }

                         run_machine(machine) = {
                           let state = 0
                           let index = 0

                           let running = true

                           while(running, {
                             value = tape_value(index)
                             commands = machine[state][value]
                             let abs_index = tape_index(index)

                             if (index >= 0,
                               tape_positive[abs_index] = commands[0]
                             ,
                               tape_negative[abs_index] = commands[0]
                             )

                             index = index + commands[1]
                             state = commands[2]

                             if (state < 0, running = false)
                           })
                         }

                         busy_beaver_score(machine) = {
                           run_machine(machine)
                           let score = 0

                           let i = 0
                           while (i < tape_positive.size(), score = score + tape_positive[i]; i = i+1)

                           let i = 0
                           while (i < tape_negative.size(), score = score + tape_negative[i]; i = i+1)

                           score
                         }
    KEISAN
                       )
  end

  it "3-state busy beaver" do
    calculator.evaluate("machine = [[[1, 1, 1], [1, -1, 2]], [[1, -1, 0], [1, 1, 1]], [[1, -1, 1], [1, 0, -1]]]")
    expect(calculator.evaluate("busy_beaver_score(machine)")).to eq 6
  end

  it "4-state busy beaver" do
    calculator.evaluate(
      <<-KEISAN
        machine = [
          [
            [1, 1, 1],
            [1, -1, 1]
          ],
          [
            [1, -1, 0],
            [0, -1, 2]
          ],
          [
            [1, 1, -1],
            [1, -1, 3]
          ],
          [
            [1, 1, 3],
            [0, 1, 0]
          ]
        ]
      KEISAN
    )
    expect(calculator.evaluate("busy_beaver_score(machine)")).to eq 13
  end
end
