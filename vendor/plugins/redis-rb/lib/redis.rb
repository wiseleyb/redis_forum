require 'socket'

class Redis
  VERSION = "2.0.0.rc2"

  class ProtocolError < RuntimeError
    def initialize(reply_type)
      super("Protocol error, got '#{reply_type}' as initial reply byte")
    end
  end

  def self.deprecate(message, trace = caller[0])
    $stderr.puts "\n#{message} (in #{trace})"
  end

  attr :client

  def self.connect(options = {})
    require "uri"

    url = URI(options.delete(:url) || ENV["REDIS_URL"] || "redis://127.0.0.1:6379/0")

    options[:host]     = url.host
    options[:port]     = url.port
    options[:password] = url.password
    options[:db]       = url.path[1..-1].to_i

    new(options)
  end

  def initialize(options = {})
    @client = Client.new(options)
  end

  def select(db)
    @client.db = db
    @client.call(:select, db)
  end

  def info
    Hash[*@client.call(:info).split(/:|\r\n/)]
  end

  def flushdb
    @client.call(:flushdb)
  end

  def save
    @client.call(:save)
  end

  def bgsave
    @client.call(:bgsave)
  end

  def get(key)
    @client.call(:get, key)
  end

  def getset(key, value)
    @client.call(:getset, key, value)
  end

  def mget(*keys)
    @client.call(:mget, *keys)
  end

  def hgetall(key)
    Hash[*@client.call(:hgetall, key)]
  end

  def hget(key, field)
    @client.call(:hget, key, field)
  end

  def hdel(key, field)
    @client.call(:hdel, key, field)
  end

  def hkeys(key)
    @client.call(:hkeys, key)
  end

  def keys(pattern = "*")
    @client.call(:keys, pattern)
  end

  def randomkey
    @client.call(:randomkey)
  end

  def echo(value)
    @client.call(:echo, value)
  end

  def ping
    @client.call(:ping)
  end

  def lastsave
    @client.call(:lastsave)
  end

  def dbsize
    @client.call(:dbsize)
  end

  def exists(key)
    _bool @client.call(:exists, key)
  end

  def llen(key)
    @client.call(:llen, key)
  end

  def lrange(key, start, stop)
    @client.call(:lrange, key, start, stop)
  end

  def ltrim(key, start, stop)
    @client.call(:ltrim, key, start, stop)
  end

  def lindex(key, index)
    @client.call(:lindex, key, index)
  end

  def lset(key, index, value)
    @client.call(:lset, key, index, value)
  end

  def lrem(key, count, value)
    @client.call(:lrem, key, count, value)
  end

  def rpush(key, value)
    @client.call(:rpush, key, value)
  end

  def lpush(key, value)
    @client.call(:lpush, key, value)
  end

  def rpop(key)
    @client.call(:rpop, key)
  end

  def blpop(key, timeout)
    @client.call_without_timeout(:blpop, key, timeout)
  end

  def brpop(key, timeout)
    @client.call_without_timeout(:brpop, key, timeout)
  end

  def rpoplpush(source, destination)
    @client.call(:rpoplpush, source, destination)
  end

  def lpop(key)
    @client.call(:lpop, key)
  end

  def smembers(key)
    @client.call(:smembers, key)
  end

  def sismember(key, member)
    _bool @client.call(:sismember, key, member)
  end

  def sadd(key, value)
    _bool @client.call(:sadd, key, value)
  end

  def srem(key, value)
    _bool @client.call(:srem, key, value)
  end

  def smove(source, destination, member)
    _bool @client.call(:smove, source, destination, member)
  end

  def spop(key)
    @client.call(:spop, key)
  end

  def scard(key)
    @client.call(:scard, key)
  end

  def sinter(*keys)
    @client.call(:sinter, *keys)
  end

  def sinterstore(destination, *keys)
    @client.call(:sinterstore, destination, *keys)
  end

  def sunion(*keys)
    @client.call(:sunion, *keys)
  end

  def sunionstore(destination, *keys)
    @client.call(:sunionstore, destination, *keys)
  end

  def sdiff(*keys)
    @client.call(:sdiff, *keys)
  end

  def sdiffstore(destination, *keys)
    @client.call(:sdiffstore, destination, *keys)
  end

  def srandmember(key)
    @client.call(:srandmember, key)
  end

  def zadd(key, score, member)
    _bool @client.call(:zadd, key, score, member)
  end

  def zincrby(key, increment, member)
    @client.call(:zincrby, key, increment, member)
  end

  def zcard(key)
    @client.call(:zcard, key)
  end

  def zrange(key, start, stop, with_scores = false)
    if with_scores
      @client.call(:zrange, key, start, stop, "WITHSCORES")
    else
      @client.call(:zrange, key, start, stop)
    end
  end

  def zrangebyscore(key, min, max)
    @client.call(:zrangebyscore, key, min, max)
  end

  def zrevrange(key, start, stop, with_scores = false)
    if with_scores
      @client.call(:zrevrange, key, start, stop, "WITHSCORES")
    else
      @client.call(:zrevrange, key, start, stop)
    end
  end

  def zscore(key, member)
    @client.call(:zscore, key, member)
  end

  def zrem(key, member)
    _bool @client.call(:zrem, key, member)
  end

  def move(key, db)
    _bool @client.call(:move, key, db)
  end

  def setnx(key, value)
    _bool @client.call(:setnx, key, value)
  end

  def del(*keys)
    _bool @client.call(:del, *keys)
  end

  def rename(old_name, new_name)
    @client.call(:rename, old_name, new_name)
  end

  def renamenx(old_name, new_name)
    _bool @client.call(:renamenx, old_name, new_name)
  end

  def expire(key, seconds)
    _bool @client.call(:expire, key, seconds)
  end

  def ttl(key)
    @client.call(:ttl, key)
  end

  def expireat(key, unix_time)
    _bool @client.call(:expireat, key, unix_time)
  end

  def hset(key, field, value)
    _bool @client.call(:hset, key, field, value)
  end

  def hmset(key, *attrs)
    @client.call(:hmset, key, *attrs)
  end

  def hlen(key)
    @client.call(:hlen, key)
  end

  def hvals(key)
    @client.call(:hvals, key)
  end

  def discard
    @client.call(:discard)
  end

  def hexists(key, field)
    _bool @client.call(:hexists, key, field)
  end

  def monitor
    raise NotImplementedError
  end

  def [](key)
    get(key)
  end

  def []=(key,value)
    set(key, value)
  end

  def set(key, value)
    @client.call(:set, key, value)
  end

  def setex(key, ttl, value)
    @client.call(:setex, key, ttl, value)
  end

  def mset(*args)
    @client.call(:mset, *args)
  end

  def mapped_mset(hash)
    mset(*hash.to_a.flatten)
  end

  def msetnx(*args)
    @client.call(:msetnx, *args)
  end

  def mapped_msetnx(hash)
    msetnx(*hash.to_a.flatten)
  end

  def mapped_mget(*keys)
    result = {}
    mget(*keys).each do |value|
      key = keys.shift
      result.merge!(key => value) unless value.nil?
    end
    result
  end

  def sort(key, options = {})
    cmd = []
    cmd << "SORT"
    cmd << key
    cmd += ["BY", options[:by]] if options[:by]

    Array(options[:get]).each do |k|
      cmd += ["GET", k]
    end if options[:get]

    cmd += options[:order].split(" ") if options[:order]
    cmd += ["LIMIT", *options[:limit]] if options[:limit]
    cmd += ["STORE", options[:store]] if options[:store]

    @client.call(*cmd)
  end

  def incr(key)
    @client.call(:incr, key)
  end

  def incrby(key, increment)
    @client.call(:incrby, key, increment)
  end

  def decr(key)
    @client.call(:decr, key)
  end

  def decrby(key, decrement)
    @client.call(:decrby, key, decrement)
  end

  def type(key)
    @client.call(:type, key)
  end

  def quit
    @client.call(:quit)
  rescue Errno::ECONNRESET
  end

  def pipelined
    original, @client = @client, Pipeline.new
    yield
    original.call_pipelined(@client.commands) unless @client.commands.empty?
  ensure
    @client = original
  end

  def exec
    @client.call(:exec)
  end

  def multi(&block)
    result = @client.call :multi

    return result unless block_given?

    begin
      yield(self)
      exec
    rescue Exception => e
      discard
      raise e
    end
  end

  def publish(channel, message)
    @client.call(:publish, channel, message)
  end

  def subscribed?
    @client.kind_of? SubscribedClient
  end

  def unsubscribe(*channels)
    raise RuntimeError, "Can't unsubscribe if not subscribed." unless subscribed?
    @client.unsubscribe(*channels)
  end

  def punsubscribe(*channels)
    raise RuntimeError, "Can't unsubscribe if not subscribed." unless subscribed?
    @client.punsubscribe(*channels)
  end

  def subscribe(*channels, &block)
    subscription(:subscribe, channels, block)
  end

  def psubscribe(*channels, &block)
    subscription(:psubscribe, channels, block)
  end

  def id
    @client.id
  end

  def method_missing(command, *args)
    @client.call(command, *args)
  end

private

  def _bool(value)
    value == 1
  end

  def subscription(method, channels, block)
    return @client.call(method, *channels) if subscribed?

    begin
      original, @client = @client, SubscribedClient.new(@client)
      @client.send(method, *channels, &block)
    ensure
      @client = original
    end
  end

end

begin
  if RUBY_VERSION >= '1.9'
    require 'timeout'
    Redis::Timer = Timeout
  else
    require 'system_timer'
    Redis::Timer = SystemTimer
  end
rescue LoadError
  Redis::Timer = nil
end

require 'redis/client'
require 'redis/pipeline'
require 'redis/subscribe'
