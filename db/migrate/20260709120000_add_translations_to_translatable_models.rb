class AddTranslationsToTranslatableModels < ActiveRecord::Migration[8.1]
  # Which plain string/text columns become Mobility-translated for each table.
  TRANSLATED = {
    products:    %w[name subtitle],
    categories:  %w[name description],
    collections: %w[name subtitle description],
    brands:      %w[name description],
    posts:       %w[title subtitle excerpt],
    slides:      %w[title subtitle price_label button_label]
  }.freeze

  def up
    TRANSLATED.each do |table, columns|
      add_column table, :translations, :jsonb, null: false, default: {}

      # Copy the existing (English) values into translations['en'], dropping keys
      # whose value is NULL so we don't store empty strings.
      pairs = columns.map { |c| "'#{c}', #{c}" }.join(", ")
      execute <<~SQL
        UPDATE #{table}
        SET translations = jsonb_build_object(
          'en', jsonb_strip_nulls(jsonb_build_object(#{pairs}))
        )
      SQL

      columns.each { |c| remove_column table, c }
    end
  end

  def down
    TRANSLATED.each do |table, columns|
      columns.each do |c|
        # name/title were NOT NULL originally; restore as plain string/text.
        type = %w[description excerpt].include?(c) ? :text : :string
        add_column table, c, type
        execute <<~SQL
          UPDATE #{table}
          SET #{c} = translations -> 'en' ->> '#{c}'
        SQL
      end

      remove_column table, :translations
    end
  end
end
