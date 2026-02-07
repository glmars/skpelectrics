require 'sketchup'
require_relative 'sketchup_edge_visitor'

module Lvm444Dev
  module SketchupVisitor

    class VertextVisitor < SketchupVisitor::EdgeVisitor
      def visit(entity)
        if entity.is_a?(Sketchup::Vertex)
          visit_vertex(entity)
        else
          super.visit(entity)
        end
      end

      def visit_edge(edge)
        group.vertices.each { |e| visit(e) }
      end

      def visit_vertex(entity)
      end
    end

  end
end
