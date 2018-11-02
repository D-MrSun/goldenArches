<%@page pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="zh-CN">
  <head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="description" content="">
    <meta name="author" content="">
	<link rel="stylesheet" href="${APP_PATH}/bootstrap/css/bootstrap.min.css">
	<link rel="stylesheet" href="${APP_PATH}/css/font-awesome.min.css">
	<link rel="stylesheet" href="${APP_PATH}/css/main.css">
	<style>
	.tree li {
        list-style-type: none;
		cursor:pointer;
	}
	.tree-closed {
	    height : 40px;
	}
	.tree-expanded {
	    height : auto;
	}
	</style>
  </head>

  <body>
  <%@include file="/WEB-INF/jsp/common/header.jsp"%>
    <div class="container-fluid">
      <div class="row">
        <div class="col-sm-3 col-md-2 sidebar">
			<div class="tree">
				<%@include file="/WEB-INF/jsp/common/menu.jsp"%>
			</div>
        </div>
        <div class="col-sm-9 col-sm-offset-3 col-md-10 col-md-offset-2 main">
          <h1 class="page-header">数据分析</h1>
          <div class="row placeholders">
            <div class="col-xs-6 col-sm-3 placeholder" style="width:1100px;height:350px;margin-bottom: 50px">
              <div id="pieChart" class="col-xs-6 col-sm-3 placeholder" style="width: 49%;height:350px;"></div>
              <div>
                <form class="form-inline">
                  <div class="form-group">
                    <div class="input-group">
                      <div class="input-group-addon">
                        <span class="glyphicon glyphicon-calendar" aria-hidden="true"></span>
                      </div>
                      <input type="text" class="form-control" id="currentDate" placeholder="请选择日期">
                    </div>
                  </div>
                  <button id="updateHorBar" class="btn btn-primary">搜索</button>
                </form>

                <div id="horizontalBar" class="col-xs-6 col-sm-3 placeholder" style="width: 51%;height:350px;"></div>
              </div>
            </div>
            <div class="col-xs-6 col-sm-3 placeholder" style="width: 95%;">
              <h3>全年销售趋势 <small>数量和金额</small></h3>
            </div>
            <div id="barChart" class="col-xs-6 col-sm-3 placeholder" style="width: 95%;height:500px;"></div>
            <div class="col-xs-6 col-sm-3 placeholder">
            </div>
          </div>
        </div>
      </div>
    </div>
    <script src="${APP_PATH}/jquery/jquery-2.1.1.min.js"></script>
    <script src="${APP_PATH}/bootstrap/js/bootstrap.min.js"></script>
	<script src="${APP_PATH}/script/docs.min.js"></script>
    <script src="${APP_PATH}/script/echarts.min.js"></script>
    <script src="${APP_PATH}/laydate/laydate.js"></script> <!-- 改成你的路径 -->
    <script type="text/javascript" src="http://echarts.baidu.com/gallery/vendors/echarts/echarts.min.js"></script>
    <script type="text/javascript" src="http://echarts.baidu.com/gallery/vendors/echarts-gl/echarts-gl.min.js"></script>
    <script type="text/javascript" src="http://echarts.baidu.com/gallery/vendors/echarts-stat/ecStat.min.js"></script>
    <script type="text/javascript" src="http://echarts.baidu.com/gallery/vendors/echarts/extension/dataTool.min.js"></script>
    <script type="text/javascript" src="http://echarts.baidu.com/gallery/vendors/echarts/map/js/china.js"></script>
    <script type="text/javascript" src="http://echarts.baidu.com/gallery/vendors/echarts/map/js/world.js"></script>
    <script type="text/javascript" src="https://api.map.baidu.com/api?v=2.0&ak=ZUONbpqGBsYGXNIYHicvbAbM"></script>
    <script type="text/javascript" src="http://echarts.baidu.com/gallery/vendors/echarts/extension/bmap.min.js"></script>
    <script type="text/javascript" src="http://echarts.baidu.com/gallery/vendors/simplex.js"></script>
    <script type="text/javascript">
        var date="";
        $(function () {
            $(".list-group-item").click(function(){
                // jquery对象的回调方法中的this关键字为DOM对象
                // $(DOM) ==> JQuery
                if ( $(this).find("ul") ) { // 3 li
                    $(this).toggleClass("tree-closed");
                    if ( $(this).hasClass("tree-closed") ) {
                        $("ul", this).hide("fast");
                    } else {
                        $("ul", this).show("fast");
                    }
                }
            });

            showPie();
            showBarChart();
            showHorizontalBar(date);
            //日期选择
            lay('#version').html('-v'+ laydate.v);
            //执行一个laydate实例
            laydate.render({
                elem: '#currentDate' //指定元素
            });
            $("#updateHorBar").click(function () {
                date =$("#currentDate").val();
                showHorizontalBar(date);
                return false;
            });
        });

        function showPie(url) {
            $.ajax({
                type : "POST",
                url  : "${APP_PATH}/chart/proTypePie",
                success : function(result) {
                    if ( result.code==100 ) {
                        var datas =result.extend.chartDatas;
                        buidPieChart(datas);
                    }
                }
            });
        }
        function buidPieChart(datas) {
            // 初始化echarts实例
            var arrayData = new Array();
            $.each( datas, function( index, data ){
                arrayData.push(data.name);
            });
            var dom = document.getElementById("pieChart");
            var myChart = echarts.init(dom);
            var app = {};
            option = null;
            option = {
                title : {
                    text: '各类商品销售情况',
                    subtext: '总销售数量',
                    x:'center'
                },
                tooltip : {
                    trigger: 'item',
                    formatter: "{a} <br/>{b} : {c} ({d}%)"
                },
                legend: {
                    orient: 'vertical',
                    left: 'left',
                    data: arrayData
                },
                series : [
                    {
                        name: '销售数量',
                        type: 'pie',
                        radius : '55%',
                        center: ['50%', '60%'],
                        data:datas,
                        itemStyle: {
                            emphasis: {
                                shadowBlur: 10,
                                shadowOffsetX: 0,
                                shadowColor: 'rgba(0, 0, 0, 0.5)'
                            }
                        }
                    }
                ]
            };
            ;
            if (option && typeof option === "object") {
                myChart.setOption(option, true);
            }
        }
        function showBarChart(url) {
            $.ajax({
                type : "POST",
                url  : "${APP_PATH}/chart/barData",
                success : function(result) {
                    if ( result.code==100 ) {
                        buildBarChart(result.extend.barData);
                    }
                }
            });
        }
        function buildBarChart(datas) {
            var dom = document.getElementById("barChart");
            var myChart = echarts.init(dom);
            var app = {};
            var option = null;
            app.title = '折柱混合';
            option = {
                tooltip: {
                    trigger: 'axis',
                    axisPointer: {
                        type: 'cross',
                        crossStyle: {
                            color: '#999'
                        }
                    }
                },
                toolbox: {
                    feature: {
                        dataView: {show: true, readOnly: false},
                        magicType: {show: true, type: ['line', 'bar']},
                        restore: {show: true},
                        saveAsImage: {show: true}
                    }
                },
                legend: {
                    data:datas.items
                },
                xAxis: [
                    {
                        type: 'category',
                        data: ['1月','2月','3月','4月','5月','6月','7月','8月','9月','10月','11月','12月'],
                        axisPointer: {
                            type: 'shadow'
                        }
                    }
                ],
                yAxis: [
                    {
                        type: 'value',
                        name: '数量',
                        min: 0,
                        max: datas.YAxis.maxCount,
                        interval: 50,
                        axisLabel: {
                            formatter: '{value} '
                        }
                    },
                    {
                        type: 'value',
                        name: '销售金额',
                        min: 0,
                        max: datas.YAxis.saleMax,
                        interval: 500,
                        axisLabel: {
                            formatter: '{value} '
                        }
                    }
                ],
                series: datas.seriesData
            };
            ;
            if (option && typeof option === "object") {
                myChart.setOption(option, true);
            }
        }

        function showHorizontalBar(date) {
            $.ajax({
                type : "POST",
                url  : "${APP_PATH}/chart/horBarData",
                data :{"date":date},
                success : function(result) {
                    if ( result.code==100 ) {
                        buildHorizontalBar(result.extend.datas);
                    }
                }
            });
        }
        function buildHorizontalBar(datas) {
            var dom = document.getElementById("horizontalBar");
            var cDate =$("#currentDate").val();
            if(""==cDate){
                cDate ="今日数据"
            }else {
                cDate =cDate+"数据";
            }
            var myChart = echarts.init(dom);
            var app = {};
            option = null;
            app.title = '当日销售金额 - 条形图';

            option = {
                title: {
                    text: '当日销售金额￥'+datas.sum,
                    subtext: cDate
                },
                tooltip: {
                    trigger: 'axis',
                    axisPointer: {
                        type: 'shadow'
                    }
                },
                grid: {
                    left: '3%',
                    right: '4%',
                    bottom: '3%',
                    containLabel: true
                },
                xAxis: {
                    type: 'value',
                    boundaryGap: [0, 0.01]
                },
                yAxis: {
                    type: 'category',
                    data: datas.nameList
                },
                series: [
                    {
                        type: 'bar',
                        data: datas.valueList
                    }
                ]
            };
            ;
            if (option && typeof option === "object") {
                myChart.setOption(option, true);
            }
        }
    </script>
  </body>
</html>
