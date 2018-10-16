from django.db import models

class LogEntry(models.Model):
    set_number = models.IntegerField()
    machine_os = models.CharField(max_length=10)
    message = models.CharField(max_length=200)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return (
            f'{self.machine_os} ({self.set_number}) at '
            f'{self.created_at.strftime("%Y-%m-%d %H:%M:%S")}: '
            f'{self.message}'
        )

