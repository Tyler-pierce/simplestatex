defmodule SimpleStatEx.Util.HandleTime do
	@moduledoc """
	Helps handle time as it pertains to roll-ups and statistics generally
	"""

	@unsupported_period "Unsupported period. SimpleStat supports these atoms: :"

	@doc """
	Round a datetime into the current day and return as a datetime

	## Examples

	  iex> SimpleStatEx.Util.HandleTime.round(:daily, #DateTime<2018-01-10 04:54:07.313053Z>)
      #DateTime<2018-01-10 00:00:00.000000Z>
	"""
	def round(:hourly, time) do
	  {{y, m, d}, {h, _, _}} = Timex.to_erl(time)

	  {:ok, Timex.to_datetime({{y, m, d}, {h, 0, 0}})}
	end

	def round(:minute, time) do
	  {{y, m, d}, {h, minute, _}} = Timex.to_erl(time)

	  {:ok, Timex.to_datetime({{y, m, d}, {h, minute, 0}})}
	end

	def round(:second, time) do
	  {{y, m, d}, {h, minute, s}} = Timex.to_erl(time)

	  {:ok, Timex.to_datetime({{y, m, d}, {h, minute, s}})}
	end

	def round(:daily, time) do
	  {:ok, Timex.beginning_of_day(time)}
	end

	def round(:weekly, time) do
	  {:ok, Timex.beginning_of_week(time)}
	end

	def round(:monthly, time) do
	  {:ok, Timex.beginning_of_month(time)}
	end

	def round(:yearly, time) do
	  {{y, _, _}, {_, _, _}} = Timex.to_erl(time)

	  {:ok, Timex.to_datetime({{y, 1, 1}, {0, 0, 0}})}
	end

	def round(_, _) do
	  {:error, get_unsupported_periods_error_msg()}
	end

	@doc """
	Return a string from a period atom if it is a supported period.

	## Examples

	  iex> SimpleStatEx.Util.HandleTime.period_to_string(:hourly)
	  "hourly"
	"""
	def period_to_string(period) do
	  if Enum.member?(get_supported_periods(), period) do
	  	{:ok, to_string(period)}
	  else
	  	{:error, get_unsupported_periods_error_msg()}
	  end
	end

	def period_to_string!(period) do
	  {:ok, period_string} = period_to_string(period)

	  period_string
	end

	defp get_supported_periods() do
	  [:minute, :second, :hourly, :daily, :weekly, :monthly, :yearly]
	end

	defp get_unsupported_periods_error_msg() do
	  @unsupported_period <> Enum.join(get_supported_periods(), ", :")
	end
end