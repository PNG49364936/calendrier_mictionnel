class ResultatsController < ApplicationController
  def index
    @dates_disponibles = JourneeObservation.par_date.pluck(:date_observation)
    @selected_dates = params[:dates] || []
    @journees = if @selected_dates.any?
                  JourneeObservation.where(date_observation: @selected_dates).par_date.includes(:entrees)
                else
                  []
                end

    @total_global_boissons = @journees.sum(&:total_boissons)
    @total_global_urine = @journees.sum(&:total_urine)

    if @journees.any?
      @stats = calculer_statistiques(@journees)
    end
  end

  def pdf
    selected_dates = (params[:dates] || []).reject(&:blank?)
    if selected_dates.empty?
      redirect_to resultats_path, alert: "Veuillez selectionner au moins une date."
      return
    end

    journees = JourneeObservation.where(date_observation: selected_dates).par_date.includes(:entrees)

    pdf = Prawn::Document.new(page_size: "A4", page_layout: :landscape)
    pdf.font_size 10

    pdf.text "Calendrier Mictionnel - Resultats", size: 18, style: :bold
    pdf.move_down 10

    journees.each do |journee|
      pdf.text "Date: #{journee.date_observation.strftime('%d/%m/%Y')} - Lever: #{journee.heure_lever&.strftime('%H:%M') || '-'} - Coucher: #{journee.heure_coucher&.strftime('%H:%M') || '-'}",
               size: 12, style: :bold
      pdf.move_down 5

      if journee.entrees.any?
        table_data = [["Heure", "Boisson (ml)", "Urine (ml)", "Urgenturies", "Fuites", "Commentaires"]]
        journee.entrees.order(:heure).each do |entree|
          table_data << [
            entree.heure&.strftime("%H:%M") || "-",
            entree.volume_boisson || "-",
            entree.volume_urine || "-",
            entree.urgenturies.presence || "-",
            entree.fuites.presence || "-",
            entree.commentaires.presence || "-"
          ]
        end
        table_data << ["Total", journee.total_boissons, journee.total_urine, "", "", ""]

        pdf.table(table_data, header: true, width: pdf.bounds.width) do |t|
          t.row(0).font_style = :bold
          t.row(0).background_color = "DDDDDD"
          t.row(-1).font_style = :bold
          t.cells.padding = [4, 6]
        end
      else
        pdf.text "Aucune entree pour cette journee.", style: :italic
      end

      pdf.move_down 15
    end

    if journees.size > 1
      pdf.text "Total Global", size: 14, style: :bold
      pdf.move_down 5
      global_data = [
        ["", "Boissons (ml)", "Urine (ml)"],
        ["Total Global", journees.sum(&:total_boissons), journees.sum(&:total_urine)]
      ]
      pdf.table(global_data, width: 300) do |t|
        t.row(0).font_style = :bold
        t.row(0).background_color = "DDDDDD"
        t.cells.padding = [4, 6]
      end
    end

    # Statistiques dans le PDF
    if journees.any?
      stats = calculer_statistiques(journees)

      pdf.move_down 15
      pdf.text "Statistiques", size: 14, style: :bold
      pdf.move_down 5

      # Moyenne miction par jour
      stats[:moyennes_par_jour].each do |m|
        pdf.text "#{m[:date]} : Moyenne miction = #{m[:moyenne]} ml (#{m[:nb_mictions]} mictions)", size: 10
      end
      if stats[:moyennes_par_jour].size > 1
        pdf.text "Global : Moyenne miction = #{stats[:moyenne_globale]} ml (#{stats[:nb_mictions_global]} mictions)", size: 10, style: :bold
      end

      pdf.move_down 5
      pdf.text "Volume miction minimum : #{stats[:miction_min][:volume]} ml le #{stats[:miction_min][:date]}", size: 10
      pdf.text "Volume miction maximum : #{stats[:miction_max][:volume]} ml le #{stats[:miction_max][:date]}", size: 10

      if stats[:top_ecarts].any?
        pdf.move_down 5
        pdf.text "Plus grands ecarts entre mictions :", size: 10, style: :bold
        stats[:top_ecarts].each_with_index do |ecart, i|
          pdf.text "#{i + 1}. Le #{ecart[:date]} : #{ecart[:heure1]} -> #{ecart[:heure2]} (#{ecart[:minutes]} min) - #{ecart[:volume]} ml", size: 10
        end
      end
    end

    send_data pdf.render,
              filename: "calendrier_mictionnel_#{Date.current.strftime('%Y%m%d')}.pdf",
              type: "application/pdf",
              disposition: "inline"
  end

  private

  def calculer_statistiques(journees)
    stats = {
      moyennes_par_jour: [],
      moyenne_globale: 0,
      nb_mictions_global: 0,
      total_urine_global: 0,
      miction_min: { volume: Float::INFINITY, date: nil },
      miction_max: { volume: 0, date: nil },
      top_ecarts: []
    }

    tous_les_ecarts = []

    journees.each do |journee|
      entrees_urine = journee.entrees.where.not(volume_urine: [nil, 0]).order(:heure)
      nb_mictions = entrees_urine.count
      total_urine_jour = entrees_urine.sum(:volume_urine)
      date_str = journee.date_observation.strftime("%d/%m/%Y")

      # Moyenne par jour
      moyenne = nb_mictions > 0 ? (total_urine_jour.to_f / nb_mictions).round(0) : 0
      stats[:moyennes_par_jour] << { date: date_str, moyenne: moyenne.to_i, nb_mictions: nb_mictions }

      stats[:nb_mictions_global] += nb_mictions
      stats[:total_urine_global] += total_urine_jour

      # Min / Max miction
      entrees_urine.each do |entree|
        vol = entree.volume_urine
        if vol < stats[:miction_min][:volume]
          stats[:miction_min] = { volume: vol, date: date_str }
        end
        if vol > stats[:miction_max][:volume]
          stats[:miction_max] = { volume: vol, date: date_str }
        end
      end

      # Ecarts entre mictions (hors nuit)
      entrees_list = entrees_urine.to_a
      entrees_list.each_cons(2) do |e1, e2|
        # Calculer l'écart en minutes entre les 2 heures
        t1 = e1.heure
        t2 = e2.heure
        minutes = ((t2 - t1) / 60).round.abs
        tous_les_ecarts << {
          date: date_str,
          heure1: t1.strftime("%H:%M"),
          heure2: t2.strftime("%H:%M"),
          minutes: minutes,
          volume: e2.volume_urine
        }
      end
    end

    # Moyenne globale
    if stats[:nb_mictions_global] > 0
      stats[:moyenne_globale] = (stats[:total_urine_global].to_f / stats[:nb_mictions_global]).round(0).to_i
    end

    # Reset min si aucune donnée
    if stats[:miction_min][:volume] == Float::INFINITY
      stats[:miction_min] = { volume: 0, date: "-" }
    end

    # Top 3 écarts les plus importants
    stats[:top_ecarts] = tous_les_ecarts.sort_by { |e| -e[:minutes] }.first(3)

    stats
  end
end
