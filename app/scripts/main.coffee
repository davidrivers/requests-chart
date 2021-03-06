require "../styles/main.less"
require "es5-shim" # For forEach usage
require "Highcharts" # Pollutes global scope. Bad like a bad bot!
dailyRequestSamples = require("../data/categorized_domain_requests.json").categorized_domain_requests

dateToUTC = (date) ->
	year = date.split("-")[0]
	month = date.split("-")[1] - 1
	day = parseInt(date.split("-")[2])
	Date.UTC(year, month, day)

humanSeries = []
goodBotSeries = []
badBotSeries = []
whitelistSeries = []
startDate = dateToUTC(dailyRequestSamples[0].summary_date)

dailyRequestSamples.forEach (entry) ->
	humanSeries.push {x: dateToUTC(entry.summary_date), y: entry.human_total } if entry.human_total
	goodBotSeries.push {x: dateToUTC(entry.summary_date), y: entry.good_bot_total } if entry.good_bot_total
	badBotSeries.push {x: dateToUTC(entry.summary_date), y: entry.bad_bot_total } if entry.bad_bot_total
	whitelistSeries.push {x: dateToUTC(entry.summary_date), y: entry.whitelist_total } if entry.whitelist_total
	return;

window.addEventListener "load", () ->
	chart = new (Highcharts.Chart)(
		chart:
			renderTo: document.getElementById "chart"
			zoomType: "x"
		title: { text: "Daily Domain Requests by Category" }
		type: "datetime"
		xAxis:
			type: "datetime"
			dateTimeLabelFormats: { day: "%b %e, %Y" }
		yAxis:
			title: { text: "Domain Requests" }
		series: [
			{ id: 1, name: "Humans", color: "#000", data: humanSeries, pointInterval: 24 * 3600 * 1000 }
			{ id: 2, name: "Good Bots", color: "green", data: goodBotSeries, pointInterval: 24 * 3600 * 1000  }
			{ id: 3, name: "Bad Bots", color: "red", data: badBotSeries, pointInterval: 24 * 3600 * 1000 }
			{ id: 4, name: "Whitelist", color: "#ccc", data: whitelistSeries, pointInterval: 24 * 3600 * 1000  } ])
	
	document.getElementById("form").addEventListener "submit", (evt) ->
		evt.preventDefault()

		requestsValue = parseInt document.getElementById("requests").value
		requestsDate = dateToUTC document.getElementById("date").value

		seriesID
		seriesRadios = document.getElementsByName "series"
		i = 0
		length = seriesRadios.length
		while i < length
			if seriesRadios[i].checked
				seriesID = parseInt seriesRadios[i].value
				break
			i++

		chart.get(seriesID).addPoint({x: requestsDate, y: requestsValue})
