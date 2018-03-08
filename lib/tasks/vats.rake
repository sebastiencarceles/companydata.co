# frozen_string_literal: true

namespace :vats do

  task create: :environment do
    Rails.logger.info "Create missing VATs"

    batch = []
    Company.where(country: "France").where.not(registration_1: ["", nil]).order(:id).find_each do |company|
      next if company.vat.present?

      key = ((12 + 3 * (company.registration_1.to_i % 97)) % 97).to_s.rjust(2, "0")
      batch << Vat.new(company_id: company.id, country_code: "FR", status: "waiting_for_validation", value: "FR#{key}#{company.registration_1}")

      if batch.count >= 10000
        Vat.import!(batch)
        Rails.logger.info "Total VATs in database: #{Vat.count}"
        batch.clear
      end
    end
    Vat.import!(batch)
    Rails.logger.info "Total VATs in database: #{Vat.count}"

    Rails.logger.info "Done"
  end

  task fetch: :environment do
    legal_forms = [
      "Autre SA coopérative à conseil d'administration ",
      "Autre SA coopérative à directoire",
      "Autre SARL coopérative ",
      "Autre personne de droit privé inscrite au registre du commerce et des sociétés",
      "Autre personne morale de droit administratif ",
      "Autre personne morale de droit privé ",
      "Autre personne morale de droit étranger ",
      "Autre société civile ",
      "Autre société civile coopérative ",
      "Autre société civile professionnelle",
      "SA coopérative (d'intérêt) maritime à conseil d'administration ",
      "SA coopérative artisanale à conseil d'administration ",
      "SA coopérative artisanale à directoire ",
      "SA coopérative d'intérêt maritime à directoire ",
      "SA coopérative de commerçants-détaillants à conseil d'administration",
      "SA coopérative de commerçants-détaillants à directoire",
      "SA coopérative de consommation à conseil d'administration ",
      "SA coopérative de consommation à directoire ",
      "SA coopérative de construction à conseil d'administration",
      "SA coopérative de production de HLM à conseil d'administration ",
      "SA coopérative de transport à conseil d'administration",
      "SA coopérative de transport à directoire ",
      "SA coopérative ouvrière de production (SCOP) à conseil d'administration",
      "SA coopérative ouvrière de production (SCOP) à directoire",
      "SA d'aménagement foncier et d'équipement rural (SAFER) à conseil d'administration",
      "SA d'attribution à conseil d'administration",
      "SA d'attribution à directoire",
      "SA d'intérêt collectif agricole (SICA)",
      "SA d'intérêt collectif agricole (SICA) à conseil d'administration",
      "SA d'économie mixte à conseil d'administration ",
      "SA d'économie mixte à directoire ",
      "SA de HLM à conseil d'administration ",
      "SA de HLM à directoire",
      "SA de crédit immobilier à conseil d'administration ",
      "SA de crédit immobilier à directoire ",
      "SA immobilière d'investissement à conseil d'administration",
      "SA immobilière pour le commerce et l'industrie (SICOMI) à conseil d'administration",
      "SA immobilière pour le commerce et l'industrie (SICOMI) à directoire",
      "SA nationale à conseil d'administration ",
      "SA nationale à directoire ",
      "SA union de sociétés coopératives à conseil d'administration ",
      "SA union de sociétés coopératives à directoire ",
      "SA à conseil d'administration (s.a.i.)",
      "SA à directoire (s.a.i.)",
      "SA à participation ouvrière à conseil d'administration ",
      "SA à participation ouvrière à directoire ",
      "SARL coopérative artisanale ",
      "SARL coopérative d'intérêt maritime ",
      "SARL coopérative de consommation ",
      "SARL coopérative de construction ",
      "SARL coopérative de transport",
      "SARL coopérative ouvrière de production (SCOP)",
      "SARL d'attribution ",
      "SARL d'intérêt collectif agricole (SICA) ",
      "SARL d'économie mixte ",
      "SARL immobilière de gestion",
      "SARL immobilière pour le commerce et l'industrie (SICOMI) ",
      "SARL mixte d'intérêt agricole (SMIA) ",
      "SARL nationale ",
      "SARL union de sociétés coopératives ",
      "SARL unipersonnelle ",
      "SAS, société par actions simplifiée",
      "Societe a responsabilite limitee",
      "Societe a responsabilite limitee  a associe unique et capital variable",
      "Societe a responsabilite limitee a associe unique",
      "Societe a responsabilite limitee a capital variable",
      "Societe a responsabilite limitee d'un Etat membre de la CE ou partie a l'accord sur l'Espace economique europeen",
      "Societe a responsabilite limitee d'un Etat non membre de la CE ou non partie a l'accord sur l'Espace economique europeen",
      "Societe anonyme",
      "Societe anonyme a conseil d'administration",
      "Societe anonyme a directoire et conseil de surveillance",
      "Societe anonyme d'un Etat membre de la CE ou partie a l'accord sur l'Espace economique europeen",
      "Societe anonyme d'un Etat non membre de la CE ou non partie a l'accord sur l'Esp",
      "Societe civile d'exploitation agricole",
      "Societe civile immobiliere",
      "Societe cooperative a forme anonyme a capital variable",
      "Societe cooperative a responsabilite limitee a capital variable",
      "Societe cooperative d'interet collectif a responsabilite limitee",
      "Societe cooperative d'interet collectif a responsabilite limitee a capital variable",
      "Societe cooperative d'interet collectif par actions simplifiee",
      "Societe cooperative d'interet collectif par actions simplifiee a capital variable",
      "Societe cooperative de production a responsabilite limitee a capital variable",
      "Societe cooperative de production par actions simplifiee",
      "Societe cooperative et participative a responsabilite limitee",
      "Societe cooperative ouvriere de production a forme anonyme",
      "Societe cooperative ouvriere de production a forme anonyme et capital variable",
      "Societe cooperative ouvriere de production a responsabilite limitee",
      "Societe d?economie mixte a operation unique",
      "Societe de droit etranger",
      "Societe de participations financieres de profession liberale de pharmacien d'officine a responsabilite limitee",
      "Societe de participations financieres de profession liberale de veterinaire a responsabilite limitee",
      "Societe de placement a preponderance immobiliere a capital variable sous la forme SAS",
      "Societe en commandite par actions",
      "Societe en commandite simple",
      "Societe en nom collectif",
      "Societe en nom collectif a capital variable",
      "Societe par actions d'un Etat membre de la CE ou partie a l'accord sur l'Espace economique europeen",
      "Societe par actions simplifiee",
      "Societe par actions simplifiee  a associe unique et capital variable",
      "Societe par actions simplifiee a associe unique",
      "Societe par actions simplifiee a capital variable",
      "Societe publique locale",
      "Société anonyme mixte d'intérêt agricole (SMIA) à conseil d'administration ",
      "Société civile coopérative d'intérêt maritime ",
      "Société civile coopérative de consommation ",
      "Société civile coopérative de construction ",
      "Société civile coopérative entre médecins ",
      "Société civile d'attribution ",
      "Société civile d'exploitation agricole ",
      "Société civile d'intérêt collectif agricole (SICA) ",
      "Société civile de moyens ",
      "Société civile de placement collectif immobilier (SCPI) ",
      "Société civile foncière ",
      "Société civile immobilière ",
      "Société civile immobilière d' accession progressive à la propriété",
      "Société civile immobilière de construction-vente",
      "Société commerciale étrangère immatriculée au RCS",
      "Société coopérative agricole ",
      "Société coopérative de banque populaire ",
      "Société coopérative de production de HLM anonyme à directoire ",
      "Société cotée en bourse",
      "Société créée de fait avec personne morale ",
      "Société créée de fait entre personnes physiques ",
      "Société d'assurance à forme mutuelle",
      "Société d'exercice libéral en commandite par actions ",
      "Société d'exercice libéral par action simplifiée ",
      "Société d'exercice libéral à forme anonyme à conseil d'administration ",
      "Société d'exercice libéral à forme anonyme à directoire ",
      "Société d'exercice libéral à responsabilité limitée ",
      "Société d'investissement à capital variable (SICAV) à conseil d'administration ",
      "Société d'investissement à capital variable (SICAV) à directoire ",
      "Société de Participations Financiere de Prof Libérale SA à Directoire (SPFPL SA à directoire)",
      "Société de Participations Financiere de Prof Libérale SA à conseil d'administration (SPFPL SA à CA)",
      "Société de Participations Financiere de Prof Libérale Société en commandite par actions (SPFPL SCA)",
      "Société de Participations Financiere de Prof Libérale Société par actions simplifiée (SPFPL SAS)",
      "Société de Participations Financiere de Prof Libérale Société à responsabilité limitée (SPFPL SARL)",
      "Société de caution mutuelle ",
      "Société de participations financières de profession libérale SA à conseil d'administration",
      "Société de participations financières de profession libérale société en commandite par actions",
      "Société de participations financières de profession libérale société par actions simplifiée",
      "Société de participations financières de profession libérale société à responsabilité limitée",
      "Société de personnes (associés)",
      "Société en commandite par actions ",
      "Société en commandite par actions coopérative ",
      "Société en commandite simple ",
      "Société en commandite simple coopérative ",
      "Société en nom collectif ",
      "Société en nom collectif coopérative ",
      "Société en participation avec personne morale ",
      "Société en participation de professions libérales ",
      "Société en participation entre personnes physiques ",
      "Société européenne ",
      "Société par actions simplifiée à associé unique ou société par actions simplifiée unipersonnelle ",
      "Société à responsabilité limitée (SRL)",
      "Société à responsabilité limitée (sans autre indication)",
      "Société étrangère non immatriculée au RCS ",
      "Sociétés Interprofessionnelles de Soins Ambulatoires",
      "Sociétés interprofessionnelles de soins ambulatoires",
    ]
    scope = Vat.where(status: "waiting_for_validation")
    count = scope.count
    scope.each_with_index do |vat, index|
      company = vat.company
      next unless company.legal_form.in?(legal_forms)
      Rails.logger.info "#{index} / #{count} - Fetch VAT for company #{company.id}: #{company.vat_number}"
    end
    Rails.logger.info "Done"
  end
end