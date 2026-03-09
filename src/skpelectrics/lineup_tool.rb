require 'sketchup'

module Lvm444Dev
  module LineupTool
    DEFAULT_TARGET_HEIGHT = 3.m
     # Here we have hard coded a special ID for the pencil cursor in SketchUp.
    CURSOR_PENCIL = 632

    def self.activate
      model = Sketchup.active_model
      if model
        tool = Tool.new
        model.select_tool(tool)
      end
    end

    class Tool
      def activate
      end

      # @param view [Sketchup::View]
      def deactivate(view)
        view.invalidate
      end

      # @param view [Sketchup::View]
      def onLButtonDown(flags, x, y, view)
        ip = view.inputpoint(x, y)
        return unless ip.valid?

        point = ip.position

        model = Sketchup.active_model
        entities = model.active_entities

        end_point = Geom::Point3d.new(point.x, point.y, DEFAULT_TARGET_HEIGHT)

        # Рисуем линию
        entities.add_line(point, end_point)
      end

      # @param view [Sketchup::View]
      def onMouseMove(flags, x, y, view)
        ip = view.inputpoint(x, y)
        return unless ip.valid?

        highlight_point(ip, view)
      end

      # @param inputpoint [Sketchup::InputPoint]
      # @param view [Sketchup::View]
      def highlight_point(inputpoint, view)
        # Рисуем круг вокруг точки привязки
        center = inputpoint.position
        radius = 20  # размер подсветки в мм
        points = []

        (0..360).step(30) do |angle|
          rad = angle * Math::PI / 180
          x = center.x + radius * Math.cos(rad)
          y = center.y + radius * Math.sin(rad)
          points << Geom::Point3d.new(x, y, center.z)
        end

        view.draw(GL_LINE_LOOP, points)
        view.invalidate
      end

      def onSetCursor
        UI.set_cursor(CURSOR_PENCIL)
      end
    end

  end
end
