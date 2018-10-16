from django.urls import path

from . import views


app_name = 'scripts'
urlpatterns = [
    path('kali/<int:set_number>/', views.kali),
    path('ubuntu/<int:set_number>/', views.ubuntu),
    path('windows7/<int:set_number>/', views.windows7),
    path('windows10/<int:set_number>/', views.windows10),
    path('wserver/<int:set_number>/', views.wserver),
]
