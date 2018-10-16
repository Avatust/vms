from functools import partial

from django.shortcuts import render
from django.urls import reverse


def _general(request, set_number, machine, template_name, filename_extension):

    this_host = request.get_host()
    context = {
        "logging_url": this_host + reverse('log_server:new'),
        "office_url": this_host + "/static/Office2016.zip",
        "machine": machine,
        "set_number": set_number
    }

    response = render(
        request,
        template_name,
        context=context,
        content_type='application/force_download',
    )

    response['Content-Disposition'] = (
        'attachment; filename='
        f'{machine}-{set_number}-deploy.{filename_extension}'
    )

    return response

_linux = partial(_general, template_name="scripts/linux/deploy.sh", filename_extension='sh')
_windows = partial(_general, template_name="scripts/windows/deploy.ps1", filename_extension='ps1')

def kali(request, set_number):
    return _linux(request=request, set_number=set_number, machine='kali')

def ubuntu(request, set_number):
    return _linux(request=request, set_number=set_number, machine='ubuntu')

def windows7(request, set_number):
    return _windows(request=request, set_number=set_number, machine='windows7')

def windows10(request, set_number):
    return _windows(request=request, set_number=set_number, machine='windows10')

def wserver(request, set_number):
    return _windows(request=request, set_number=set_number, machine='wserver')
