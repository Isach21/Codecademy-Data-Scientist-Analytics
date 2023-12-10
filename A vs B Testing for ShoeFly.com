import codecademylib3
import pandas as pd

ad_clicks = pd.read_csv('ad_clicks.csv')
#1
print(ad_clicks.head())
#2
views_utm_source = ad_clicks.groupby("utm_source").user_id.count().reset_index()
print(views_utm_source)
#3
ad_clicks["is_click"] = ~ad_clicks\
  .ad_click_timestamp.isnull()
#4
clicks_by_source = ad_clicks.groupby(["utm_source", "is_click"]).user_id.count().reset_index()
print(clicks_by_source.head())
#5
clicks_pivot = clicks_by_source.pivot(
  columns = "is_click",
  index = "utm_source",
  values= "user_id").reset_index()
print(clicks_pivot)
#6
clicks_pivot["percent_clicked"] = clicks_pivot[True]/ (clicks_pivot[True] + clicks_pivot[False])
print(clicks_pivot)
#7
ad_a_b = ad_clicks.groupby("experimental_group").user_id.count().reset_index()
print(ad_a_b)
#8
ad_a_b_click = ad_clicks.groupby(["experimental_group","is_click"]).user_id.count().reset_index()
ad_a_b_click_pv = ad_a_b_click.pivot(
  columns = "is_click",
  index = "experimental_group",
  values= "user_id").reset_index()
ad_a_b_click_pv["percent_clicked"] = ad_a_b_click_pv[True]/ (ad_a_b_click_pv[True] + ad_a_b_click_pv[False])
print(ad_a_b_click_pv)
#9
a_clicks = ad_clicks[ad_clicks.experimental_group == "A"]
b_clicks = ad_clicks[ad_clicks.experimental_group == "B"]
#10
#a
click_day_a = a_clicks.groupby(["day", "is_click"]).user_id.count().reset_index()
click_day_a = click_day_a.pivot(
  columns = "is_click",
  index = "day",
  values= "user_id").reset_index()
click_day_a["percent_clicked"] = click_day_a[True]/ (click_day_a[True] + click_day_a[False])
print(click_day_a)
#b
click_day_b = b_clicks.groupby(["day", "is_click"]).user_id.count().reset_index()
click_day_b = click_day_b.pivot(
  columns = "is_click",
  index = "day",
  values= "user_id").reset_index()

click_day_b["percent_clicked"] = click_day_b[True]/ (click_day_b[True] + click_day_b[False])
print(click_day_b)
#11
diference = click_day_b.percent_clicked - click_day_a.percent_clicked
print(diference)
