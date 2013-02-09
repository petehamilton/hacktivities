refresh_data = ->
  $.getJSON $('#stats-link').val(), (data) ->
    process_stats(data)

    # Refresh data every 15 seconds
    setTimeout ->
      refresh_data()
    , 15000

process_stats = (data) ->
  timed_stats = data.timed_stats

  participant_count = data.total_participants
  average_team_size = data.average_team_size

  draw_chart(timed_stats)

draw_chart = (timed_stats) ->
  hours = (moment(k).format('MMM Do, ha') for k, v of timed_stats).reverse()
  commit_totals = (v.total_commits for k, v of timed_stats).reverse()
  commit_averages = (v.average_commits for k, v of timed_stats).reverse()
  message_length_averages = (v.average_message_length for k, v of timed_stats).reverse()
  swearword_count_totals = (v.total_swearword_count for k, v of timed_stats).reverse()
  swearword_count_averages = (v.average_total_swearword_count for k, v of timed_stats).reverse()

  chart = new Highcharts.Chart(
    chart:
      renderTo: "stats"
      type: "line"
      margin: [ 50, 50, 100, 80]

    title:
      text: "Live Hackathon Stats"
      x: -20 #center

    subtitle:
      text: "Source: Github Repositories"
      x: -20

    xAxis:
      title:
        text: "Time"
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
      layout: "vertical"
      align: "right"
      verticalAlign: "top"
      x: -10
      y: 100
      borderWidth: 0

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
