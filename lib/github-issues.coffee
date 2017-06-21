# Handle the GitHub "issues" event
#
# Usage:
#
# require('../lib/github-issues')(robot, room, data)
#
# OR
#
# github_issues = require '../lib/github-issues'
# github_issues robot, room, data

module.exports = (robot, room, payload) ->
  return if not payload.issue?
  return if not payload.action?
  return if not payload.action in ["opened", "closed", "reopened"]

  action = payload.action
  repo = payload.repository.full_name
  user_name = payload.issue.user.login
  user_url = payload.issue.user.html_url
  issue_id = payload.issue.number
  issue_title = payload.issue.title
  issue_url = payload.issue.html_url
  issue_content = payload.issue.body

  switch action
    when "opened" then ts = new Date payload.issue.created_at
    when "closed" then ts = new Date payload.issue.closed_at
    when "reopened" then ts = new Date payload.issue.updated_at

  ts = new Date ts.getTime()
  ts = Math.floor(ts.getTime() / 1000)

  attachment =
    attachments: [
      fallback: "[#{repo}] Issue [##{issue_id}](#{issue_url}) #{action} by [#{user_name}](#{user_url})"
      color: "warning"
      pretext: "[#{repo}] Issue #{action} by [#{user_name}](#{user_url})"
      author_name: "#{repo} (GitHub)"
      author_link: "https://github.com/#{repo}"
      author_icon: "https://a.slack-edge.com/2fac/plugins/github/assets/service_36.png"
      title: "##{issue_id} #{issue_title}"
      title_link: issue_url
      text: issue_content
      footer: "GitHub"
      footer_icon: "https://a.slack-edge.com/2fac/plugins/github/assets/service_36.png"
      ts: ts
    ]

  robot.send room: room, attachment
