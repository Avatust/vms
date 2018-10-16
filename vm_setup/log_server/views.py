from django.http import HttpResponse, HttpResponseRedirect
from django.urls import reverse

from .models import LogEntry


def index(request):
    last_entries = LogEntry.objects.order_by('-created_at')[:100]
    joined = '\n'.join(str(entry) for entry in last_entries)
    return HttpResponse(joined, content_type='text/plain')

def new(request):
    try:
        machine_os = request.POST['machine_os']
        set_number = request.POST['set_number']
        message = request.POST['message']

        new_le = LogEntry(machine_os=machine_os, set_number=set_number, message=message)
        new_le.save()

    except KeyError:
        pass

    return HttpResponseRedirect(reverse('log_server:index'))

