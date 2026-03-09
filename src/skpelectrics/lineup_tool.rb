require 'sketchup'

module Lvm444Dev
  module LineupTool
    DEFAULT_TARGET_HEIGHT = 3000.mm
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
        @mouse_ip = Sketchup::InputPoint.new
      end

      # @param view [Sketchup::View]
      def deactivate(view)
        view.invalidate
      end

      # @param view [Sketchup::View]
      def onLButtonDown(flags, x, y, view)
        @mouse_ip.pick(view, x, y)
        return unless @mouse_ip.valid?

        point = @mouse_ip.position

        model = Sketchup.active_model
        entities = model.active_entities

        end_point = Geom::Point3d.new(point.x, point.y, DEFAULT_TARGET_HEIGHT)

        # Рисуем линию
        entities.add_line(point, end_point)
        view.invalidate
      end

      # @param view [Sketchup::View]
      def onMouseMove(flags, x, y, view)
        @mouse_ip.pick(view, x, y)
        view.tooltip = @mouse_ip.tooltip if @mouse_ip.valid?
        view.invalidate
      end

      # @param view [Sketchup::View]
      def draw(view)
        @mouse_ip.draw(view) if @mouse_ip.display?
        draw_preview(view)
      end

      def onSetCursor
        UI.set_cursor(CURSOR_PENCIL)
      end

      private

      # @param view [Sketchup::View]
      def draw_preview(view)
        return unless @mouse_ip.valid?

        point = @mouse_ip.position
        end_point = Geom::Point3d.new(point.x, point.y, DEFAULT_TARGET_HEIGHT)

        view.set_color_from_line(point, end_point)
        view.line_width = 1
        view.line_stipple = ''
        view.draw(GL_LINES, [point, end_point])
      end
    end

  end
end
