require "testup/testcase"

module Lvm444Dev

  class TC_ElectricLines < TestUp::TestCase
    @lines = []

    def setup
      @lines = Lvm444Dev::SketchupUtils.search_electric_lines
    end

    def test_search
      assert_equal(3, @lines.size)
    end

    def test_length
      length = @lines.map{ |line| line.length }.sum

      assert_in_delta(20.502, length)
    end

    def test_attributes
      line = get_line('02-РОЗ-Кухня Плита (no wirings)')

      assert_equal('02', line.line_number)
      assert_equal('РОЗ', line.type)
      assert_equal('Кухня', line.room)
      assert_equal('Плита (no wirings)', line.description)
    end

    def test_reserves
      reserves = get_line('03-ОСВ-Кухня').reserves

      assert_equal({'' => 6}, reserves)
    end

    def test_reserves_simple
      reserves = get_line('02-РОЗ-Кухня Плита (no wirings)').reserves

      assert_equal({'' => 2}, reserves)
    end

    def test_reserves_complex
      reserves = get_line('01-РОЗ-Кухня').reserves

      assert_equal({'' => 6}, reserves)
    end

    private
    # @return [Lvm444Dev::ElectricLineModel] электрическая линия
    def get_line(name)
      @lines.find(proc { flunk("Line not found: #{name}") }) do |line|
        line.to_desc == name
      end
    end
  end

end
