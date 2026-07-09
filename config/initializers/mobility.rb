# Mobility stores model translations. We use the :container backend, which keeps
# every translated attribute for a record inside a single jsonb column named
# `translations` (e.g. {"en" => {"name" => "..."}, "ru" => {...}}).
#
# Missing ru/ky values fall back to English so the storefront never shows blanks.
Mobility.configure do
  plugins do
    backend :container

    active_record

    reader
    writer

    backend_reader
    query
    dirty

    fallbacks(ru: :en, ky: :en)
    presence

    # Generates name_en / name_ru / name_ky style accessors for admin forms.
    locale_accessors [ :en, :ru, :ky ]
  end
end
