require "pagy/extras/overflow"
require "pagy/extras/bootstrap"

Pagy::DEFAULT[:limit] = 12
Pagy::DEFAULT[:overflow] = :last_page
