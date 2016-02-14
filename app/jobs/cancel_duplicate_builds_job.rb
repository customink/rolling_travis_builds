class CancelDuplicateBuildsJob

  include SuckerPunch::Job

  def perform(webhook_repo)
    TravisApi.cancel_duplicate_builds!(webhook_repo)
  end

end
