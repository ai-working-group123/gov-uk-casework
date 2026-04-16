module CasesHelper
  def status_badge(kase)
    if kase.sla_deadline && kase.sla_deadline < Time.current && !%w[decided_approved decided_refused withdrawn].include?(kase.status)
      content_tag(:strong, "OVERDUE", class: "tag-red")
    else
      tag_classes = {
        "submitted" => "tag-blue",
        "assigned" => "tag-blue",
        "in_review" => "tag-yellow",
        "awaiting_evidence" => "tag-orange",
        "ready_for_decision" => "tag-purple",
        "decided_approved" => "tag-green",
        "decided_refused" => "tag-red",
        "withdrawn" => "tag-grey"
      }
      css = tag_classes[kase.status] || "tag-grey"
      content_tag(:strong, kase.status.humanize, class: css)
    end
  end

  def priority_badge(kase)
    tag_classes = {
      "low" => "tag-green",
      "medium" => "tag-yellow",
      "high" => "tag-red",
      "urgent" => "tag-red"
    }
    css = tag_classes[kase.priority] || "tag-grey"
    content_tag(:strong, kase.priority.humanize, class: css)
  end

  def evidence_status_icon(evidence)
    case evidence.status
    when "accepted", "received" then "✅"
    when "rejected" then "❌"
    when "not_received" then "❌"
    when "under_review" then "🔍"
    else "⬜"
    end
  end

  def days_overdue(kase)
    return nil unless kase.sla_deadline && kase.sla_deadline < Time.current
    ((Time.current - kase.sla_deadline) / 1.day).to_i
  end

  def action_priority_icon(action)
    case action.status
    when "pending" then "🔴"
    when "in_progress" then "🟡"
    when "blocked" then "🟡"
    when "completed" then "🟢"
    else "⬜"
    end
  end

  def timeline_icon(note)
    case note.note_type
    when "system" then "⚙️"
    when "decision" then "⚖️"
    when "evidence" then "📎"
    else "💬"
    end
  end

  def timeline_author(note)
    if note.note_type == "system"
      "SYSTEM"
    elsif note.caseworker
      note.caseworker.name
    else
      "Applicant"
    end
  end
end
