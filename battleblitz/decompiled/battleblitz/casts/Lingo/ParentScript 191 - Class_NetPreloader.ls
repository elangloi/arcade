property netID, url, status, done

on new me, urlString
  isDone = 0
  url = urlString
  me.startStream()
  status = getStreamStatus(url)
  return me
end

on destroy me
  if not netDone(netID) then
    netAbort(netID)
  end if
  return VOID
end

on startStream me
  if url <> string(the moviePath & the movieName) then
    netID = preloadNetThing(url)
  end if
  status = getStreamStatus(url)
end

on update me
  status = getStreamStatus(url)
  done = status.state = "Complete"
  return done
end

on getState me
  return status.state
end

on getRatioLoaded me
  if status.bytesTotal = 0 then
    return 0.0
  else
    return status.bytesSoFar / float(status.bytesTotal)
  end if
end

on getBytesTotal me
  return status.bytesTotal
end

on getBytesLoaded me
  return status.bytesSoFar
end

on GetUrl me
  return url
end

on isDone me
  return done
end
