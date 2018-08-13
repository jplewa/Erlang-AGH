defmodule MnesiaData do
  @moduledoc false
  def loadModules() do
    IEx.Helpers.c("./mnesia_data.ex")
  end
  def importLinesFromCSV(filename) do
    File.read!(filename) |> String.split()
  end
  # %{:datetime ⇒ {{2017,5,22},{13,23,30}}, :location ⇒ {19.992,50.081}, :pollutionLevel ⇒ 96}
  def convertLineIntoMap(line) do
    [date, time, y, x, value] = String.split(line, ",")
    value = Integer.parse(value) |> elem(0)
    location = Enum.map([y,x], fn a -> Float.parse(a) |> elem(0) end) |> List.to_tuple
    date = String.split(date, "-") |> Enum.map(fn x -> elem(Integer.parse(x),0) end) |>
      Enum.reverse |> List.to_tuple
    time = String.split(time, ":") |> Enum.map(fn x -> elem(Integer.parse(x),0) end) |> (& &1 ++[0]).() |> List.to_tuple
    %{:datetime => {date, time}, :location => location, :pollutionLevel => value}
  end
  def identifyStations(list) do
    Enum.reduce(list, %{}, fn reading, acc -> Map.put(acc, reading.location, :station) end)
  end

  def addAllStations(map) do
    map = Enum.map(Map.to_list(map), fn {{x,y}, :station} -> {to_charlist("station_#{x}_#{y}"),{x,y}} end)
    fn -> Enum.map(map, fn {name, location} -> :pollutionMnesia.addStation(name, location) end) end |> :timer.tc |> elem(0)
  end
  def addAllValues(list) do
    fn -> Enum.map(list,
            fn %{:datetime => datetime, :location => location, :pollutionLevel => pollutionLevel}
            -> :pollutionMnesia.addValue(location, datetime, to_charlist("PM10"), pollutionLevel) end) end |> :timer.tc |> elem(0)
  end
  def addCSVData() do
    loadModules()
    list = importLinesFromCSV("./pollution.csv") |> Enum.map(fn x -> convertLineIntoMap(x) end)
    stations = identifyStations(list) |> addAllStations
    values = addAllValues(list)
    {stations/1000000, values/1000000}
  end
#  def getStationMean() do
#    result = :pollution_gen_server.getStationMean({20.06, 49.986}, "PM10")
#    list = for _ <- :lists.seq(1,100), do: elem(:timer.tc(fn -> :pollution_gen_server.getStationMean({20.06, 49.986}, "PM10") end), 0)
#    {:lists.min(list)/1000000, result}
#  end
#  def getDailyMean() do
#    result = :pollution_gen_server.getDailyMean({2017, 5, 3}, "PM10")
#    list = for _ <- :lists.seq(1, 100), do: elem(:timer.tc(fn -> :pollution_gen_server.getDailyMean({2017, 5, 3}, "PM10") end), 0)
#    {:lists.min(list)/1000000, result}
#  end
#  def getDeviation() do
#    result = :pollution_gen_server.getDeviation({2017,5,3}, 0, "PM10")
#    list = for _ <- :lists.seq(1, 100), do: elem(:timer.tc(fn -> :pollution_gen_server.getDeviation({2017,5,3}, 0, "PM10") end), 0)
#    {:lists.min(list)/1000000, result}
#  end
end

