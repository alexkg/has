class << ActiveRecord::Base

  def has(*xs)
    opt = xs.extract_options!
    name = xs.pop if xs.last.kind_of?(Symbol)

    argument_name_for = { Range => :range, Fixnum => :count }
    while x = xs.shift
      opt[argument_name_for[x.class]] = x
    end

    if key = (opt.keys & [ :attributed, :nested ]).first
      send "has_#{key}", opt.delete(key), opt
    else
      has_associated name, opt
    end
  end

  def has_attributed(name, opt = {})
    opt[:include] = true if opt[:include].nil?
    opt[:conditions] ||= {}
    opt[:conditions][:attribute_name] = name.to_s
    opt[:orderable] = :attribute_ordinal if opt[:orderable] == true
    opt[:as] = :attributable

    has_nested name, opt
  end

  def has_nested(name, opt = {})
    opt[:dependent] = :destroy if opt[:dependent].nil?
    allow_destroy   = opt[:dependent] == :destroy
    default_include = opt.delete(:include) == true
    if orderable    = opt.delete(:orderable)
      opt[:order]   = orderable
    end

    has_associated name, opt

    accepts_nested_attributes_for name, allow_destroy: allow_destroy
    default_scope includes(name) if default_include

    if orderable
      setter = instance_method setter_name = "#{name}_attributes="

      define_method setter_name do |attr|
        attr = attr.values if attr.is_a? Hash
        attr.each_with_index{ |e, i| e[orderable] = i }
        setter.bind(self).call attr
        send(name).sort_by! &orderable
      end

      before_save do
        send(name).each_with_index{ |e, i| e[orderable] = i }
      end
    end
  end

  def has_associated(name, opt = {})
    range = opt.delete :range
    count = opt.delete :count
    inf   = 1.0/0
    min   = opt.keys.find{ |k| Integer === k }
    max   = opt.delete min if min
    max   = inf if max == :many

    range ||= if count then count .. count
    elsif min && max then min .. max
    else
      name_s = name.to_s
      is_plural = name_s.pluralize == name_s
      is_singular = name_s.singularize == name_s

      raise ArgumentError.new "`has` can't determine whether \"#{name_s}\" is plural or singular. Please supply a count or range, or define an inflection." if is_plural == is_singular

      0 .. (is_plural ? inf : 1)
    end

    if range.end == 1 then has_one name, opt
    else
      opt[:limit] = range.end unless range.end == inf
      has_many name, opt
    end

    validates_presence_of name if range.begin > 0
  end

end
