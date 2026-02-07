require 'sketchup'
require_relative 'sketchup_edge_visitor'

module Lvm444Dev
  module ElectricLine

    class LengthCalculator < SketchupVisitor::EdgeVisitor
      attr_reader :length
      @@INCH_SCALE = 0.0254

      def initialize
        @length = 0.0
      end

      def visit_edge(edge)
        @length += edge.length * @@INCH_SCALE
      end
    end

  end
end
