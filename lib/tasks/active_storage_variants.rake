namespace :active_storage do
  desc "Pre-generate all named variants for existing attachments (idempotent, safe to re-run)"
  task backfill_variants: :environment do
    # Models that declare named variants on their attachments.
    models = [ Product, Category, Collection, Slide, Brand, Post ]

    checked = 0
    errored = 0

    models.each do |model|
      model.attachment_reflections.each do |name, reflection|
        variants = reflection.named_variants.keys
        next if variants.empty?

        # with_attached_<name> preloads attachments, blobs, and existing variant
        # records so the idempotency check below doesn't N+1.
        model.public_send("with_attached_#{name}").find_each do |record|
          proxy = record.public_send(name)
          attachments =
            if reflection.macro == :has_many_attached
              proxy.attachments
            else
              [ proxy.attachment ].compact
            end

          attachments.each do |attachment|
            next unless attachment.blob&.image?

            variants.each do |variant|
              checked += 1
              begin
                attachment.variant(variant).processed # generates only if missing
                print "."
              rescue => e
                errored += 1
                warn "\n#{model.name}##{record.id} #{name}:#{variant} -> #{e.class}: #{e.message}"
              end
            end
          end
        end
      end
    end

    puts "\nDone. Checked #{checked} variant(s), #{errored} error(s)."
  end
end
