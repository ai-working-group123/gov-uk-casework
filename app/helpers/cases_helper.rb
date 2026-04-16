module CasesHelper
  def status_badge(kase)
    if kase.sla_deadline && kase.sla_deadline < Time.current && !%w[decided_approved decided_refused withdrawn].include?(kase.status)
      content_tag(:span, "⚠️ OVERDUE", class: "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-red-100 text-red-800")
    else
      colors = {
        "submitted" => "bg-blue-100 text-blue-800",
        "assigned" => "bg-blue-100 text-blue-800",
        "in_review" => "bg-yellow-100 text-yellow-800",
        "awaiting_evidence" => "bg-yellow-100 text-yellow-800",
        "ready_for_decision" => "bg-purple-100 text-purple-800",
        "decided_approved" => "bg-green-100 text-green-800",
        "decided_refused" => "bg-red-100 text-red-800",
        "withdrawn" => "bg-gray-100 text-gray-800"
      }
      css = colors[kase.status] || "bg-gray-100 text-gray-800"
      content_tag(:span, kase.status.humanize, class: "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium #{css}")
    end
  end

  def priority_badge(kase)
    colors = {
      "low" => "bg-green-100 text-green-800",
      "medium" => "bg-yellow-100 text-yellow-800",
      "high" => "bg-red-100 text-red-800",
      "urgent" => "bg-red-200 text-red-900"
    }
    icons = { "low" => "🟢", "medium" => "🟡", "high" => "🔴", "urgent" => "🔴" }
    css = colors[kase.priority] || "bg-gray-100 text-gray-800"
    content_tag(:span, "#{icons[kase.priority]} #{kase.priority.humanize}", class: "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium #{css}")
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
