import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

abstract class WeatherApi {
  static Future<WeatherData> getWeatherForCity({
    required Location location,
  }) async {
    var uri = Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=${location.latitude}&longitude=${location.longitude}&hourly=temperature_2m,relative_humidity_2m,apparent_temperature,rain,snowfall,snow_depth,weather_code,surface_pressure,wind_speed_10m&daily=sunrise,sunset,daylight_duration,sunshine_duration,uv_index_max&start_date=2024-07-15&end_date=2024-07-17');

    final response = await http.get(uri);

    int statusCode = response.statusCode;
    if (statusCode >= 200 && statusCode < 300) {
      return WeatherData.fromJson(response.body);
    } else {
      // TODO: Better error's
      throw Exception('Failed to load weather data');
    }
  }

  static Future<List<WeatherData>> getWeatherForCities({
    required List<Location> locations,
  }) async {
    if (locations.isEmpty) {
      return [];
    }

    if (locations.length == 1) {
      return [
        await getWeatherForCity(
          location: locations.first,
        ),
      ];
    }

    var uri = Uri.parse(
      'https://api.open-meteo.com/v1/forecast?latitude=${locations.map((e) => e.latitude).join(",")}&longitude=${locations.map((e) => e.longitude).join(",")}&hourly=temperature_2m,relative_humidity_2m,apparent_temperature,rain,snowfall,snow_depth,weather_code,surface_pressure,wind_speed_10m&daily=sunrise,sunset,daylight_duration,sunshine_duration,uv_index_max&start_date=2024-07-15&end_date=2024-07-17',
    );

    final response = await http.get(uri);

    int statusCode = response.statusCode;
    if (statusCode >= 200 && statusCode < 300) {
      return (jsonDecode(response.body) as List)
          .map((element) => WeatherData.fromMap(element))
          .toList();
    } else {
      // TODO: Better error's
      throw Exception('Failed to load weather data');
    }
  }
}

@immutable
class Location {
  final double latitude;
  final double longitude;

  const Location({
    required this.latitude,
    required this.longitude,
  });
}

@immutable
class WeatherData {
  final double latitude;
  final double longitude;
  final double generationtimeMs;
  final int utcOffsetSeconds;
  final String timezone;
  final String timezoneAbbreviation;
  final double elevation;

  // Units
  final String timeUnit;
  final String temperature2mUnit;
  final String relativeHumidity2mUnit;
  final String apparentTemperatureUnit;
  final String rainUnit;
  final String snowfallUnit;
  final String snowDepthUnit;
  final String weatherCodeUnit;
  final String surfacePressureUnit;
  final String windSpeed10mUnit;

  final List<HourlyWeatherData> hourlyWeatherData;
  final List<DailyWeatherData> dailyWeatherData;

  const WeatherData({
    required this.latitude,
    required this.longitude,
    required this.generationtimeMs,
    required this.utcOffsetSeconds,
    required this.timezone,
    required this.timezoneAbbreviation,
    required this.elevation,
    required this.timeUnit,
    required this.temperature2mUnit,
    required this.relativeHumidity2mUnit,
    required this.apparentTemperatureUnit,
    required this.rainUnit,
    required this.snowfallUnit,
    required this.snowDepthUnit,
    required this.weatherCodeUnit,
    required this.surfacePressureUnit,
    required this.windSpeed10mUnit,
    required this.hourlyWeatherData,
    required this.dailyWeatherData,
  });

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'generationtime_ms': generationtimeMs,
      'utc_offset_seconds': utcOffsetSeconds,
      'timezone': timezone,
      'timezone_abbreviation': timezoneAbbreviation,
      'elevation': elevation,
      'time_unit': timeUnit,
      'temperature_2m_unit': temperature2mUnit,
      'relative_humidity_2m_unit': relativeHumidity2mUnit,
      'apparent_temperature_unit': apparentTemperatureUnit,
      'rain_unit': rainUnit,
      'snowfall_unit': snowfallUnit,
      'snow_depth_unit': snowDepthUnit,
      'weather_code_unit': weatherCodeUnit,
      'surface_pressure_unit': surfacePressureUnit,
      'winds_speed_10m_unit': windSpeed10mUnit,
      'hourly_weather_data': hourlyWeatherData.map((x) => x.toMap()).toList(),
      'daily_weather_data': dailyWeatherData.map((x) => x.toMap()).toList(),
    };
  }

  factory WeatherData.fromMap(Map<String, dynamic> map) {
    // Parse the hourly data
    final List<DateTime> time = (map['hourly']['time'] as List<dynamic>)
        .map((element) => DateTime.parse(element.toString()))
        .toList();
    final List<double> temperature2m =
        map['hourly']['temperature_2m'].cast<double>();
    final List<int> relativeHumidity2m =
        map['hourly']['relative_humidity_2m'].cast<int>();
    final List<double> apparentTemperature =
        map['hourly']['apparent_temperature'].cast<double>();
    final List<double> rain = map['hourly']['rain'].cast<double>();
    final List<double> snowfall = map['hourly']['snowfall'].cast<double>();
    final List<double> snowDepth = map['hourly']['snow_depth'].cast<double>();
    final List<int> weatherCode = map['hourly']['weather_code'].cast<int>();
    final List<double> surfacePressure =
        map['hourly']['surface_pressure'].cast<double>();
    final List<double> windSpeed10m =
        map['hourly']['wind_speed_10m'].cast<double>();

    List<HourlyWeatherData> hourlyWeatherData = [];
    for (var i = 0; i < time.length; i++) {
      hourlyWeatherData.add(
        HourlyWeatherData(
          time: time[i],
          temperature2m: temperature2m[i],
          relativeHumidity2m: relativeHumidity2m[i],
          apparentTemperature: apparentTemperature[i],
          rain: rain[i],
          snowfall: snowfall[i],
          snowDepth: snowDepth[i],
          weatherCode: weatherCode[i],
          surfacePressure: surfacePressure[i],
          windSpeed10m: windSpeed10m[i],
        ),
      );
    }

    // Parse the daily data
    final List<DateTime> date = (map['daily']['time'] as List<dynamic>)
        .map((element) => DateTime.parse(element.toString()))
        .toList();

    final List<DateTime> sunrise = (map['daily']['sunrise'] as List<dynamic>)
        .map((element) => DateTime.parse(element.toString()))
        .toList();

    final List<DateTime> sunset = (map['daily']['sunset'] as List<dynamic>)
        .map((element) => DateTime.parse(element.toString()))
        .toList();

    final List<double> daylightDuration =
        map['daily']['daylight_duration'].cast<double>();
    final List<double> sunshineDuration =
        map['daily']['sunshine_duration'].cast<double>();
    final List<double> uvIndexMax = map['daily']['uv_index_max'].cast<double>();

    // Units
    final String daylightDurationUnit =
        map['daily_units']['daylight_duration'] as String;
    final String sunshineDurationUnit =
        map['daily_units']['sunshine_duration'] as String;

    List<DailyWeatherData> dailyWeatherData = [];
    for (var i = 0; i < date.length; i++) {
      dailyWeatherData.add(
        DailyWeatherData(
          date: date[i],
          sunrise: sunrise[i],
          sunset: sunset[i],
          daylightDuration: daylightDuration[i],
          sunshineDuration: sunshineDuration[i],
          uvIndexMax: uvIndexMax[i],
          daylightDurationUnit: daylightDurationUnit,
          sunshineDurationUnit: sunshineDurationUnit,
        ),
      );
    }

    return WeatherData(
      latitude: map['latitude'].toDouble(),
      longitude: map['longitude'].toDouble(),
      generationtimeMs: map['generationtime_ms'].toDouble(),
      utcOffsetSeconds: map['utc_offset_seconds'].toInt(),
      timezone: map['timezone'],
      timezoneAbbreviation: map['timezone_abbreviation'],
      elevation: map['elevation'].toDouble(),
      timeUnit: map['hourly_units']['time'],
      temperature2mUnit: map['hourly_units']['temperature_2m'],
      relativeHumidity2mUnit: map['hourly_units']['relative_humidity_2m'],
      apparentTemperatureUnit: map['hourly_units']['apparent_temperature'],
      rainUnit: map['hourly_units']['rain'],
      snowfallUnit: map['hourly_units']['snowfall'],
      snowDepthUnit: map['hourly_units']['snow_depth'],
      weatherCodeUnit: map['hourly_units']['weather_code'],
      surfacePressureUnit: map['hourly_units']['surface_pressure'],
      windSpeed10mUnit: map['hourly_units']['wind_speed_10m'],
      hourlyWeatherData: hourlyWeatherData,
      dailyWeatherData: dailyWeatherData,
    );
  }

  String toJson() => json.encode(toMap());

  factory WeatherData.fromJson(String source) =>
      WeatherData.fromMap(json.decode(source));
}

@immutable
class HourlyWeatherData {
  final DateTime time;
  final double temperature2m;
  final int relativeHumidity2m;
  final double apparentTemperature;
  final double rain;
  final double snowfall;
  final double snowDepth;
  final int weatherCode;
  final double surfacePressure;
  final double windSpeed10m;

  const HourlyWeatherData({
    required this.time,
    required this.temperature2m,
    required this.relativeHumidity2m,
    required this.apparentTemperature,
    required this.rain,
    required this.snowfall,
    required this.snowDepth,
    required this.weatherCode,
    required this.surfacePressure,
    required this.windSpeed10m,
  });

  Map<String, dynamic> toMap() {
    return {
      'time': time.millisecondsSinceEpoch,
      'temperature_2m': temperature2m,
      'relative_humidity_2m': relativeHumidity2m,
      'apparent_temperature': apparentTemperature,
      'rain': rain,
      'snowfall': snowfall,
      'snow_depth': snowDepth,
      'weather_code': weatherCode,
      'surface_pressure': surfacePressure,
      'wind_speed_10m': windSpeed10m,
    };
  }

  factory HourlyWeatherData.fromMap(Map<String, dynamic> map) {
    return HourlyWeatherData(
      time: DateTime.parse(map['time']),
      temperature2m: map['temperature_2m'].toDouble(),
      relativeHumidity2m: map['relative_humidity_2m'].toInt(),
      apparentTemperature: map['apparent_temperature'].toDouble(),
      rain: map['rain'].toDouble(),
      snowfall: map['snowfall'].toDouble(),
      snowDepth: map['snow_depth'].toDouble(),
      weatherCode: map['weather_code'].toInt(),
      surfacePressure: map['surface_pressure'].toDouble(),
      windSpeed10m: map['wind_speed_10m'].toDouble(),
    );
  }

  String toJson() => json.encode(toMap());

  factory HourlyWeatherData.fromJson(String source) =>
      HourlyWeatherData.fromMap(json.decode(source));
}

@immutable
class DailyWeatherData {
  final DateTime date;
  final DateTime sunrise;
  final DateTime sunset;
  final double daylightDuration;
  final double sunshineDuration;
  final double uvIndexMax;

  // Units
  final String daylightDurationUnit;
  final String sunshineDurationUnit;

  const DailyWeatherData({
    required this.date,
    required this.sunrise,
    required this.sunset,
    required this.daylightDuration,
    required this.sunshineDuration,
    required this.uvIndexMax,
    required this.daylightDurationUnit,
    required this.sunshineDurationUnit,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date.millisecondsSinceEpoch,
      'sunrise': sunrise.millisecondsSinceEpoch,
      'sunset': sunset.millisecondsSinceEpoch,
      'daylight_duration': daylightDuration,
      'sunshine_duration': sunshineDuration,
      'uv_index_max': uvIndexMax,
      'daylight_duration_unit': daylightDurationUnit,
      'sunshine_duration_unit': sunshineDurationUnit,
    };
  }

  factory DailyWeatherData.fromMap(Map<String, dynamic> map) {
    return DailyWeatherData(
      date: DateTime.parse(map['date']),
      sunrise: DateTime.parse(map['sunrise']),
      sunset: DateTime.parse(map['sunset']),
      daylightDuration: map['daylight_duration'].toDouble(),
      sunshineDuration: map['sunshine_duration'].toDouble(),
      uvIndexMax: map['uv_index_max'].toDouble(),
      daylightDurationUnit: map['daylight_duration_unit'],
      sunshineDurationUnit: map['sunshine_duration_unit'],
    );
  }

  String toJson() => json.encode(toMap());

  factory DailyWeatherData.fromJson(String source) =>
      DailyWeatherData.fromMap(json.decode(source));
}
