module AdminHelper
  def admin_nav_link(name, path, icon:, active_when: nil)
    active = active_when.nil? ? current_page?(path) : active_when
    base = "flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium transition"
    classes = active ? "#{base} bg-indigo-600 text-white shadow" : "#{base} text-gray-300 hover:bg-gray-800 hover:text-white"
    link_to path, class: classes do
      concat content_tag(:i, "", class: "las #{icon} text-xl")
      concat content_tag(:span, name)
    end
  end

  def admin_controller?(*names)
    names.map(&:to_s).include?(controller_name)
  end

  # Small colored badge, e.g. status pills.
  def status_badge(text, color: :gray)
    palette = {
      green: "bg-green-100 text-green-800",
      red: "bg-red-100 text-red-800",
      yellow: "bg-yellow-100 text-yellow-800",
      indigo: "bg-indigo-100 text-indigo-800",
      gray: "bg-gray-100 text-gray-700"
    }
    content_tag(:span, text, class: "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium #{palette[color]}")
  end

  def boolean_badge(value, true_text: "Yes", false_text: "No")
    value ? status_badge(true_text, color: :green) : status_badge(false_text, color: :gray)
  end

  # --- shared Tailwind class strings ---
  def input_classes
    "w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-indigo-500 focus:ring-1 focus:ring-indigo-500 outline-none"
  end

  def label_classes
    "block text-sm font-medium text-gray-700 mb-1"
  end

  def btn_primary
    "inline-flex items-center gap-2 bg-indigo-600 hover:bg-indigo-700 text-white text-sm font-medium px-4 py-2 rounded-lg transition cursor-pointer"
  end

  def btn_secondary
    "inline-flex items-center gap-2 bg-white border border-gray-300 hover:bg-gray-50 text-gray-700 text-sm font-medium px-4 py-2 rounded-lg transition cursor-pointer"
  end

  def btn_danger
    "inline-flex items-center gap-2 bg-red-600 hover:bg-red-700 text-white text-sm font-medium px-4 py-2 rounded-lg transition cursor-pointer"
  end

  def admin_form_errors(record)
    return if record.errors.empty?
    content_tag(:div, class: "mb-4 rounded-lg bg-red-50 border border-red-200 px-4 py-3 text-sm text-red-700") do
      content_tag(:ul, class: "list-disc list-inside space-y-0.5") do
        safe_join(record.errors.full_messages.map { |m| content_tag(:li, m) })
      end
    end
  end
end
