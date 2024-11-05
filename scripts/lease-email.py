#    Licensed under the Apache License, Version 2.0 (the "License"); you may
#    not use this file except in compliance with the License. You may obtain
#    a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#    License for the specific language governing permissions and limitations
#    under the License.

import argparse
import datetime
import email.message
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
import json
import pathlib
import smtplib

import openstack

import esi


def send_email(from_email, to_email, subject, body,
               smtp_server, smtp_port, smtp_username, smtp_password):
    msg = MIMEMultipart()
    msg.attach(MIMEText(body, 'html'))
    msg['From'] = from_email
    msg['To'] = to_email
    msg['Subject'] = subject

    with smtplib.SMTP(smtp_server, smtp_port) as mailer:
        mailer.starttls()
        mailer.login(smtp_username, smtp_password)
        mailer.send_message(msg)


def get_project_emails(project_id, role_assignments, users):
    project_user_ids = [r['user']['id'] for r in role_assignments if 'project' in r['scope'] and r['scope']['project']['id'] == project_id]    
    emails = [u.email for u in users if u.id in project_user_ids and u.email]
    return emails


def get_relevant_leases(esi_conn, lease_filter={}):
    leases = list(esi_conn.lease.leases())
    if lease_filter.get("filter", None) == 'expiring':
        return [l for l in leases if datetime.datetime.strptime(l.end_time[:19], '%Y-%m-%dT%H:%M:%S') < datetime.datetime.now() + datetime.timedelta(days=lease_filter['within'])]
    return leases


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("email_config_file", type=str, help="'reminder' or 'expiring'")
    args = parser.parse_args()

    with open(args.email_config_file) as f:
        email_config = json.load(f)

    smtp_server = email_config['smtp_server']
    smtp_port = email_config['smtp_port']
    smtp_username = email_config['smtp_username']
    smtp_password = email_config['smtp_password']
    smtp_from = email_config['smtp_from']
    subject_template = email_config['subject_template']
    body_template = email_config['body_template']
    lease_filter = email_config.get("lease_filter", {})

    conn = openstack.connect()
    esi_conn = esi.connect()

    projects = list(conn.identity.projects())
    users = list(conn.identity.users())
    leases = get_relevant_leases(esi_conn, lease_filter)
    role_assignments = list(conn.identity.role_assignments())
    
    # iterate through projects and find their leases (if any)
    for project in projects:
        project_leases = [l for l in leases if l.project_id == project.id]

        if len(project_leases) > 0:
            header_format = "<tr align='left'><th>{:<30}</th><th align='left'>{:<40}</th><th align='left'>{:<40}</th></tr>"
            row_format = "<tr><td align='left'>{:<30}</td><td align='left'>{:<40}</td><td align='left'>{:<40}</td></tr>"
            header_string = header_format.format("NODE", "LEASE START TIME", "LEASE END TIME")
            lease_string = "".join(
                [row_format.format(l.resource, l.start_time, l.end_time) for l in project_leases])
            lease_table = "<table cellpadding='5'>" + header_string + lease_string + "</table>"

            # get users associated with project
            emails = get_project_emails(project.id, role_assignments, users)
            if len(emails) > 0:
                to = ','.join(emails)
                subject = subject_template.format(project=project.name)
                body = body_template.format(lease_table=lease_table)
                print("Sending email to %s" % to)
                send_email(smtp_from, to, subject, body, smtp_server, smtp_port, smtp_username, smtp_password)

if __name__ == "__main__":
    main()
