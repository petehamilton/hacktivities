refresh_data = ->
  $.getJSON $('#stats-link').val(), (data) ->
    if data.api_error?
      $('#github-api-error-message').show()
      $('.github-api-stats').hide()
    else
      $('#github-api-error-message').hide()
      $('.github-api-stats').show()
      process_stats(data)
  .error ->
    $('#system-error').show()
    $('.github-api-stats').hide()

    # Refresh data every 60 seconds
    setTimeout ->
      refresh_data()
    , 15 * 1000

process_stats = (data) ->
  $("#stat-total-participants").html(data.total_participants)
  $("#stat-average-team-size").html(data.average_team_size)

  draw_chart(data.timed_stats)

draw_chart = (timed_stats) ->
  timed_stats = $(timed_stats)
  hours = timed_stats.map (k, v) -> moment(v.date).format('MMM Do, ha')
  commit_totals = timed_stats.map (k, v) -> v.stats.total_commits
  commit_averages = timed_stats.map (k, v) -> v.stats.average_commits
  message_length_averages = timed_stats.map (k, v) -> v.stats.average_message_length
  swearword_count_totals = timed_stats.map (k, v) -> v.stats.total_swearword_count
  swearword_count_averages = timed_stats.map (k, v) -> v.stats.average_total_swearword_count

  chart = new Highcharts.Chart(
    chart:
      renderTo: "stats"
      type: "line"
      margin: [40, 10, 120, 10]
      height: 300

    title:
      text: "Live Hackathon Repository Stats"
      x: -20 #center

    xAxis:
      title:
        text: ""
      categories: hours
      labels:
        align: "right"
        rotation: -45,

    yAxis: [
      title: ""
      min: 0
      labels:
       enabled: false
    ,
      title: ""
      min: 0
      labels:
       enabled: false
    ,
      title: ""
      min: 0
      labels:
       enabled: false
    ]


    tooltip:
      formatter: ->
        "<b>#{@series.name} during #{@x}</b><br/>#{@y}"

    legend:
      # layout: "vertical"
      # align: "right"
      # verticalAlign: "top"
      # x: -10
      y: 0
      # borderWidth: 0

    series: [
      name: "Total Commits"
      data: commit_totals
      yAxis: 0
    ,
      name: "Per-Hack Commits"
      data: commit_averages
      yAxis: 0
    ,
      name: "Message Length (Avg)"
      data: message_length_averages
      yAxis: 1
    ,
      name: "Commit Message Swearwords"
      data: swearword_count_totals
      yAxis: 2
    ,
    ]
  )


$(document).ready ->
  hostname = window.location.hostname
  $("a[href^=http]").not("a[href*='" + hostname + "']").addClass("link external").attr "target", "_blank"
  $("[rel='tooltip']").tooltip()
  $(".btn.disabled").live "click", (e) ->
    e.preventDefault()
  $('.btn-delete').bind 'click', (e) ->
    e.preventDefault()
    answer = confirm("Are you sure?")
    if answer
      $.ajax
        type: "DELETE"
        url: $(this).attr('href')
      .success ->
        window.location.reload()
  if $('#stats').length > 0
    refresh_data()

    # Refresh page every 10 minutes
    setTimeout ->
      refresh_data()
    , 60 * 10 * 1000
