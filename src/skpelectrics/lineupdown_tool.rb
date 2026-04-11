require 'sketchup'

module Lvm444Dev
  module LineupdownTool
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
        @picked_ip = Sketchup::InputPoint.new
        @target_height = Lvm444Dev::SkpElectrics::Settings.get_lineupdown_target_height || 3000.mm
        update_ui
      end

      def deactivate(view)
        view.invalidate
      end

      def onLButtonDown(flags, x, y, view)
        @mouse_ip.pick(view, x, y)
        return unless @mouse_ip.valid?
        @picked_ip.copy!(@mouse_ip)

        point = @mouse_ip.position
        end_point = Geom::Point3d.new(point.x, point.y, @target_height)

        entities = Sketchup.active_model.active_entities
        entities.add_line(point, end_point)

        update_ui
        view.invalidate
      end

      def onMouseMove(flags, x, y, view)
        @mouse_ip.pick(view, x, y)
        view.tooltip = @mouse_ip.tooltip if @mouse_ip.valid?
        view.invalidate
      end

      def draw(view)
        draw_preview(view)
        @mouse_ip.draw(view) if @mouse_ip.display?
      end

      def enableVCB?
        true
      end

      # @param text [String]
      def onUserText(text, view)
        begin
          @target_height = text.to_l
          Lvm444Dev::SkpElectrics::Settings.set_lineupdown_target_height(@target_height)
          update_ui
        rescue ArgumentError
          UI.messagebox('Введена недопустимая высота')
        end
      end

      def resume(view)
        update_ui
        view.invalidate
      end

      def suspend(view)
        view.invalidate
      end

      def onSetCursor
        UI.set_cursor(CURSOR_PENCIL)
      end

      private

      def update_ui
        Sketchup.vcb_label = 'Высота потолков (0 - рисовать до пола)'
        Sketchup.vcb_value = @target_height.to_s
        Sketchup.status_text = 'Кликните для выбора начальной точки'
      end

      def draw_preview(view)
        draw_picked_ip(view)
        draw_reserves(view)
      end

      def draw_picked_ip(view)
        draw_reserve(@picked_ip.position, view) if @picked_ip.valid?
      end

      def draw_reserves(view)
        lines = Lvm444Dev::SkpElectricsLinesManager.search_electric_lines
        lines.each { |line| draw_line_reserves(line, view) }
      end

      # @param line [Lvm444Dev::ElectricLineModel]
      def draw_line_reserves(line, view)
        cable_ends = Lvm444Dev::ElectricLine::CableEnds.new
        cable_ends.visit(line.get_group)
        cable_ends.ends.each { |vertex| draw_reserve(vertex.position, view) }
      end

      # @param point [Geom::Point3d]
      # @param view [Sketchup::View]
      def draw_reserve(point, view)
        reserve_length = 300.mm
        end_point = Geom::Point3d.new(point.x, point.y, point.z - reserve_length)

        view.line_width = 2
        view.line_stipple = '.'
        view.drawing_color = 'BlueViolet'
        view.draw_line(point, end_point)

        screen_text_point = view.screen_coords(end_point)
        view.draw_text(screen_text_point, reserve_length.to_s,
          { bold: true, color: 'BlueViolet' })
      end
    end

  end
end
