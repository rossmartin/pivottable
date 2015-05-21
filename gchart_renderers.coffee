(->
  callWithJQuery = undefined

  callWithJQuery = (pivotModule) ->
    if typeof exports == 'object' and typeof module == 'object'
      pivotModule require('jquery')
    else if typeof define == 'function' and define.amd
      define [ 'jquery' ], pivotModule
    else
      pivotModule jQuery

  callWithJQuery ($) ->
    makeGoogleChart = undefined

    makeGoogleChart = (chartType, extraOptions) ->
      (pivotData, opts) ->
        agg = undefined
        colKey = undefined
        colKeys = undefined
        dataArray = undefined
        dataTable = undefined
        defaults = undefined
        fullAggName = undefined
        groupByTitle = undefined
        h = undefined
        hAxisTitle = undefined
        headers = undefined
        i = undefined
        j = undefined
        k = undefined
        len = undefined
        len1 = undefined
        numCharsInHAxis = undefined
        options = undefined
        ref = undefined
        result = undefined
        row = undefined
        rowKey = undefined
        rowKeys = undefined
        title = undefined
        tree2 = undefined
        v = undefined
        vAxisTitle = undefined
        val = undefined
        wrapper = undefined
        x = undefined
        y = undefined
        defaults =
          localeStrings:
            vs: 'vs'
            by: 'by'
          gchart:
            width: ->
              window.innerWidth / 1.4
            height: ->
              window.innerHeight / 1.4
        opts = $.extend(defaults, opts)
        rowKeys = pivotData.getRowKeys()
        if rowKeys.length == 0
          rowKeys.push []
        colKeys = pivotData.getColKeys()
        if colKeys.length == 0
          colKeys.push []
        fullAggName = pivotData.aggregatorName
        if pivotData.valAttrs.length
          fullAggName += '(' + pivotData.valAttrs.join(', ') + ')'
        headers = do ->
          `var j`
          `var len`
          `var i`
          i = undefined
          len = undefined
          results = undefined
          results = []
          while i < len
            h = rowKeys[i]
            results.push h.join('-')
            i++
          results
        headers.unshift ''
        numCharsInHAxis = 0
        if chartType == 'ScatterChart'
          dataArray = []
          ref = pivotData.tree
          for y of ref
            `y = y`
            tree2 = ref[y]
            for x of tree2
              `x = x`
              agg = tree2[x]
              dataArray.push [
                parseFloat(x)
                parseFloat(y)
                fullAggName + ': \n' + agg.format(agg.value())
              ]
          dataTable = new (google.visualization.DataTable)
          dataTable.addColumn 'number', pivotData.colAttrs.join('-')
          dataTable.addColumn 'number', pivotData.rowAttrs.join('-')
          dataTable.addColumn
            type: 'string'
            role: 'tooltip'
          dataTable.addRows dataArray
          hAxisTitle = pivotData.colAttrs.join('-')
          vAxisTitle = pivotData.rowAttrs.join('-')
          title = ''
        else
          dataArray = [ headers ]
          i = 0
          len = colKeys.length
          while i < len
            colKey = colKeys[i]
            row = [ colKey.join('-') ]
            numCharsInHAxis += row[0].length
                        j = 0
            len1 = rowKeys.length
            while j < len1
              rowKey = rowKeys[j]
              agg = pivotData.getAggregator(rowKey, colKey)
              if agg.value() != null
                val = agg.value()
                if $.isNumeric(val)
                  if val < 1
                    row.push parseFloat(val.toPrecision(3))
                  else
                    precision = if typeof opts.gchart.dataPrecision != 'undefined' then opts.gchart.dataPrecision else 3
                    row.push parseFloat(val.toFixed(precision))
                else
                  row.push val
              else
                row.push null
              j++
            dataArray.push row
            i++
          dataTable = google.visualization.arrayToDataTable(dataArray)
          title = vAxisTitle = fullAggName
          hAxisTitle = pivotData.colAttrs.join('-')
          if hAxisTitle != ''
            title += ' ' + opts.localeStrings.vs + ' ' + hAxisTitle
          groupByTitle = pivotData.rowAttrs.join('-')
          if groupByTitle != ''
            title += ' ' + opts.localeStrings.by + ' ' + groupByTitle
        console.log 'title: ', title
        options =
          width: opts.gchart.width()
          height: opts.gchart.height()
          title: title
          hAxis:
            title: hAxisTitle
            slantedText: numCharsInHAxis > 50
          vAxis: title: vAxisTitle
          tooltip: textStyle:
            fontName: 'Arial'
            fontSize: 12
        if chartType == 'ColumnChart'
          options.vAxis.minValue = 0
        if chartType == 'ScatterChart'
          options.legend = position: 'none'
          options.chartArea =
            'width': '80%'
            'height': '80%'
        else if dataArray[0].length == 2 and dataArray[0][1] == ''
          options.legend = position: 'none'
        for k of extraOptions
          `k = k`
          v = extraOptions[k]
          options[k] = v
        if opts.gchart.extras
          for j of opts.gchart.extras
            options[j] = opts.gchart.extras[j]
        result = $('<div>').css(
          width: '100%'
          height: '100%')
        wrapper = new (google.visualization.ChartWrapper)(
          dataTable: dataTable
          chartType: chartType
          options: options)
        wrapper.draw result[0]
        result.bind 'dblclick', ->
          editor = undefined
          editor = new (google.visualization.ChartEditor)
          google.visualization.events.addListener editor, 'ok', ->
            editor.getChartWrapper().draw result[0]
          editor.openDialog wrapper
        result

    $.pivotUtilities.gchart_renderers =
      'Line Chart': makeGoogleChart('LineChart')
      'Bar Chart': makeGoogleChart('ColumnChart')
      'Stacked Bar Chart': makeGoogleChart('ColumnChart', isStacked: true)
      'Area Chart': makeGoogleChart('AreaChart', isStacked: true)
      'Scatter Chart': makeGoogleChart('ScatterChart')
  return
).call this
