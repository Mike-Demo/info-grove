export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export type Database = {
  // Allows to automatically instantiate createClient with right options
  // instead of createClient<Database, { PostgrestVersion: 'XX' }>(URL, KEY)
  __InternalSupabase: {
    PostgrestVersion: "14.18"
  }
  public: {
    Tables: {
      authors: {
        Row: {
          avatar_id: string | null
          bio: string | null
          created_at: string
          id: string
          name: string
          slug: string
          social: Json | null
          updated_at: string
        }
        Insert: {
          avatar_id?: string | null
          bio?: string | null
          created_at?: string
          id: string
          name: string
          slug: string
          social?: Json | null
          updated_at?: string
        }
        Update: {
          avatar_id?: string | null
          bio?: string | null
          created_at?: string
          id?: string
          name?: string
          slug?: string
          social?: Json | null
          updated_at?: string
        }
        Relationships: []
      }
      categories: {
        Row: {
          created_at: string
          description: string | null
          id: string
          name: string
          parent_id: string | null
          slug: string
          updated_at: string
        }
        Insert: {
          created_at?: string
          description?: string | null
          id: string
          name: string
          parent_id?: string | null
          slug: string
          updated_at?: string
        }
        Update: {
          created_at?: string
          description?: string | null
          id?: string
          name?: string
          parent_id?: string | null
          slug?: string
          updated_at?: string
        }
        Relationships: []
      }
      contact_submissions: {
        Row: {
          created_at: string
          email: string
          id: string
          message: string
          name: string
          topic: string | null
          updated_at: string
        }
        Insert: {
          created_at?: string
          email: string
          id: string
          message: string
          name: string
          topic?: string | null
          updated_at?: string
        }
        Update: {
          created_at?: string
          email?: string
          id?: string
          message?: string
          name?: string
          topic?: string | null
          updated_at?: string
        }
        Relationships: []
      }
      customer_stories: {
        Row: {
          body: Json
          company: string | null
          created_at: string
          id: string
          published_at: string | null
          related_product_ids: string[]
          scheduled_at: string | null
          seo_description: string | null
          seo_image: string | null
          seo_title: string | null
          slug: string
          status: string
          title: string
          updated_at: string
        }
        Insert: {
          body?: Json
          company?: string | null
          created_at?: string
          id: string
          published_at?: string | null
          related_product_ids?: string[]
          scheduled_at?: string | null
          seo_description?: string | null
          seo_image?: string | null
          seo_title?: string | null
          slug: string
          status?: string
          title: string
          updated_at?: string
        }
        Update: {
          body?: Json
          company?: string | null
          created_at?: string
          id?: string
          published_at?: string | null
          related_product_ids?: string[]
          scheduled_at?: string | null
          seo_description?: string | null
          seo_image?: string | null
          seo_title?: string | null
          slug?: string
          status?: string
          title?: string
          updated_at?: string
        }
        Relationships: []
      }
      event_registrations: {
        Row: {
          attendance: string
          created_at: string
          email: string
          event_id: string
          id: string
          name: string
          updated_at: string
          user_id: string | null
        }
        Insert: {
          attendance?: string
          created_at?: string
          email: string
          event_id: string
          id: string
          name: string
          updated_at?: string
          user_id?: string | null
        }
        Update: {
          attendance?: string
          created_at?: string
          email?: string
          event_id?: string
          id?: string
          name?: string
          updated_at?: string
          user_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "event_registrations_event_id_fkey"
            columns: ["event_id"]
            isOneToOne: false
            referencedRelation: "events"
            referencedColumns: ["id"]
          },
        ]
      }
      events: {
        Row: {
          capacity: number
          created_at: string
          description: Json
          end_at: string
          hero_id: string | null
          id: string
          online_url: string | null
          published_at: string | null
          registration_open: boolean
          scheduled_at: string | null
          seo_description: string | null
          seo_image: string | null
          seo_title: string | null
          slug: string
          speaker_ids: string[]
          start_at: string
          status: string
          timezone: string
          title: string
          updated_at: string
          venue: string | null
        }
        Insert: {
          capacity?: number
          created_at?: string
          description?: Json
          end_at: string
          hero_id?: string | null
          id: string
          online_url?: string | null
          published_at?: string | null
          registration_open?: boolean
          scheduled_at?: string | null
          seo_description?: string | null
          seo_image?: string | null
          seo_title?: string | null
          slug: string
          speaker_ids?: string[]
          start_at: string
          status?: string
          timezone?: string
          title: string
          updated_at?: string
          venue?: string | null
        }
        Update: {
          capacity?: number
          created_at?: string
          description?: Json
          end_at?: string
          hero_id?: string | null
          id?: string
          online_url?: string | null
          published_at?: string | null
          registration_open?: boolean
          scheduled_at?: string | null
          seo_description?: string | null
          seo_image?: string | null
          seo_title?: string | null
          slug?: string
          speaker_ids?: string[]
          start_at?: string
          status?: string
          timezone?: string
          title?: string
          updated_at?: string
          venue?: string | null
        }
        Relationships: []
      }
      faqs: {
        Row: {
          answer: Json
          category_id: string | null
          created_at: string
          id: string
          question: string
          sort_order: number
          updated_at: string
        }
        Insert: {
          answer?: Json
          category_id?: string | null
          created_at?: string
          id: string
          question: string
          sort_order?: number
          updated_at?: string
        }
        Update: {
          answer?: Json
          category_id?: string | null
          created_at?: string
          id?: string
          question?: string
          sort_order?: number
          updated_at?: string
        }
        Relationships: []
      }
      feedback: {
        Row: {
          created_at: string
          id: string
          message: string | null
          page: string | null
          sentiment: string | null
          updated_at: string
          user_id: string | null
        }
        Insert: {
          created_at?: string
          id: string
          message?: string | null
          page?: string | null
          sentiment?: string | null
          updated_at?: string
          user_id?: string | null
        }
        Update: {
          created_at?: string
          id?: string
          message?: string | null
          page?: string | null
          sentiment?: string | null
          updated_at?: string
          user_id?: string | null
        }
        Relationships: []
      }
      job_applications: {
        Row: {
          consent: boolean
          cover_letter: string | null
          created_at: string
          email: string
          id: string
          job_id: string
          name: string
          portfolio_url: string | null
          resume_file_name: string | null
          state: string
          updated_at: string
          user_id: string | null
        }
        Insert: {
          consent?: boolean
          cover_letter?: string | null
          created_at?: string
          email: string
          id: string
          job_id: string
          name: string
          portfolio_url?: string | null
          resume_file_name?: string | null
          state?: string
          updated_at?: string
          user_id?: string | null
        }
        Update: {
          consent?: boolean
          cover_letter?: string | null
          created_at?: string
          email?: string
          id?: string
          job_id?: string
          name?: string
          portfolio_url?: string | null
          resume_file_name?: string | null
          state?: string
          updated_at?: string
          user_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "job_applications_job_id_fkey"
            columns: ["job_id"]
            isOneToOne: false
            referencedRelation: "jobs"
            referencedColumns: ["id"]
          },
        ]
      }
      jobs: {
        Row: {
          created_at: string
          department: string | null
          description: string | null
          id: string
          location: string | null
          open: boolean
          slug: string
          title: string
          updated_at: string
        }
        Insert: {
          created_at?: string
          department?: string | null
          description?: string | null
          id: string
          location?: string | null
          open?: boolean
          slug: string
          title: string
          updated_at?: string
        }
        Update: {
          created_at?: string
          department?: string | null
          description?: string | null
          id?: string
          location?: string | null
          open?: boolean
          slug?: string
          title?: string
          updated_at?: string
        }
        Relationships: []
      }
      media_assets: {
        Row: {
          alt: string
          caption: string | null
          created_at: string
          focal_point: Json | null
          height: number
          id: string
          mime_type: string
          path: string
          size_bytes: number
          updated_at: string
          width: number
        }
        Insert: {
          alt: string
          caption?: string | null
          created_at?: string
          focal_point?: Json | null
          height?: number
          id: string
          mime_type: string
          path: string
          size_bytes?: number
          updated_at?: string
          width?: number
        }
        Update: {
          alt?: string
          caption?: string | null
          created_at?: string
          focal_point?: Json | null
          height?: number
          id?: string
          mime_type?: string
          path?: string
          size_bytes?: number
          updated_at?: string
          width?: number
        }
        Relationships: []
      }
      newsletter_subscriptions: {
        Row: {
          consent: boolean
          created_at: string
          email: string
          id: string
          updated_at: string
        }
        Insert: {
          consent?: boolean
          created_at?: string
          email: string
          id: string
          updated_at?: string
        }
        Update: {
          consent?: boolean
          created_at?: string
          email?: string
          id?: string
          updated_at?: string
        }
        Relationships: []
      }
      notifications: {
        Row: {
          body: string | null
          created_at: string
          href: string | null
          id: string
          read_at: string | null
          title: string
          type: string
          updated_at: string
          user_id: string
        }
        Insert: {
          body?: string | null
          created_at?: string
          href?: string | null
          id: string
          read_at?: string | null
          title: string
          type?: string
          updated_at?: string
          user_id: string
        }
        Update: {
          body?: string | null
          created_at?: string
          href?: string | null
          id?: string
          read_at?: string | null
          title?: string
          type?: string
          updated_at?: string
          user_id?: string
        }
        Relationships: []
      }
      orders: {
        Row: {
          created_at: string
          currency: string
          id: string
          items: Json
          name: string
          order_state: string
          owner_email: string
          payment_state: string
          shipping_address: Json
          shipping_minor: number
          subtotal_minor: number
          tax_minor: number
          total_minor: number
          updated_at: string
        }
        Insert: {
          created_at?: string
          currency?: string
          id: string
          items?: Json
          name: string
          order_state?: string
          owner_email: string
          payment_state?: string
          shipping_address?: Json
          shipping_minor?: number
          subtotal_minor?: number
          tax_minor?: number
          total_minor?: number
          updated_at?: string
        }
        Update: {
          created_at?: string
          currency?: string
          id?: string
          items?: Json
          name?: string
          order_state?: string
          owner_email?: string
          payment_state?: string
          shipping_address?: Json
          shipping_minor?: number
          subtotal_minor?: number
          tax_minor?: number
          total_minor?: number
          updated_at?: string
        }
        Relationships: []
      }
      pages: {
        Row: {
          blocks: Json
          created_at: string
          id: string
          locale: string
          published_at: string | null
          scheduled_at: string | null
          seo_description: string | null
          seo_image: string | null
          seo_title: string | null
          slug: string
          status: string
          summary: string | null
          template: string
          title: string
          updated_at: string
        }
        Insert: {
          blocks?: Json
          created_at?: string
          id: string
          locale?: string
          published_at?: string | null
          scheduled_at?: string | null
          seo_description?: string | null
          seo_image?: string | null
          seo_title?: string | null
          slug: string
          status?: string
          summary?: string | null
          template?: string
          title: string
          updated_at?: string
        }
        Update: {
          blocks?: Json
          created_at?: string
          id?: string
          locale?: string
          published_at?: string | null
          scheduled_at?: string | null
          seo_description?: string | null
          seo_image?: string | null
          seo_title?: string | null
          slug?: string
          status?: string
          summary?: string | null
          template?: string
          title?: string
          updated_at?: string
        }
        Relationships: []
      }
      posts: {
        Row: {
          author_id: string | null
          body: Json
          category_ids: string[]
          created_at: string
          excerpt: string | null
          hero_id: string | null
          id: string
          locale: string
          published_at: string | null
          related_post_ids: string[]
          scheduled_at: string | null
          search: unknown
          seo_description: string | null
          seo_image: string | null
          seo_title: string | null
          slug: string
          status: string
          tag_ids: string[]
          title: string
          updated_at: string
        }
        Insert: {
          author_id?: string | null
          body?: Json
          category_ids?: string[]
          created_at?: string
          excerpt?: string | null
          hero_id?: string | null
          id: string
          locale?: string
          published_at?: string | null
          related_post_ids?: string[]
          scheduled_at?: string | null
          search?: unknown
          seo_description?: string | null
          seo_image?: string | null
          seo_title?: string | null
          slug: string
          status?: string
          tag_ids?: string[]
          title: string
          updated_at?: string
        }
        Update: {
          author_id?: string | null
          body?: Json
          category_ids?: string[]
          created_at?: string
          excerpt?: string | null
          hero_id?: string | null
          id?: string
          locale?: string
          published_at?: string | null
          related_post_ids?: string[]
          scheduled_at?: string | null
          search?: unknown
          seo_description?: string | null
          seo_image?: string | null
          seo_title?: string | null
          slug?: string
          status?: string
          tag_ids?: string[]
          title?: string
          updated_at?: string
        }
        Relationships: []
      }
      product_reviews: {
        Row: {
          body: string | null
          created_at: string
          id: string
          moderation: string
          product_id: string
          rating: number
          reviewer_name: string
          title: string | null
          updated_at: string
          user_id: string | null
        }
        Insert: {
          body?: string | null
          created_at?: string
          id: string
          moderation?: string
          product_id: string
          rating: number
          reviewer_name: string
          title?: string | null
          updated_at?: string
          user_id?: string | null
        }
        Update: {
          body?: string | null
          created_at?: string
          id?: string
          moderation?: string
          product_id?: string
          rating?: number
          reviewer_name?: string
          title?: string | null
          updated_at?: string
          user_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "product_reviews_product_id_fkey"
            columns: ["product_id"]
            isOneToOne: false
            referencedRelation: "products"
            referencedColumns: ["id"]
          },
        ]
      }
      product_variants: {
        Row: {
          created_at: string
          currency: string
          id: string
          options: Json
          price_minor: number
          product_id: string
          sku: string
          stock: number
          updated_at: string
        }
        Insert: {
          created_at?: string
          currency?: string
          id: string
          options?: Json
          price_minor: number
          product_id: string
          sku: string
          stock?: number
          updated_at?: string
        }
        Update: {
          created_at?: string
          currency?: string
          id?: string
          options?: Json
          price_minor?: number
          product_id?: string
          sku?: string
          stock?: number
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "product_variants_product_id_fkey"
            columns: ["product_id"]
            isOneToOne: false
            referencedRelation: "products"
            referencedColumns: ["id"]
          },
        ]
      }
      products: {
        Row: {
          availability: string
          category_ids: string[]
          created_at: string
          description: Json
          gallery_ids: string[]
          id: string
          name: string
          published_at: string | null
          related_product_ids: string[]
          scheduled_at: string | null
          seo_description: string | null
          seo_image: string | null
          seo_title: string | null
          slug: string
          status: string
          tag_ids: string[]
          updated_at: string
        }
        Insert: {
          availability?: string
          category_ids?: string[]
          created_at?: string
          description?: Json
          gallery_ids?: string[]
          id: string
          name: string
          published_at?: string | null
          related_product_ids?: string[]
          scheduled_at?: string | null
          seo_description?: string | null
          seo_image?: string | null
          seo_title?: string | null
          slug: string
          status?: string
          tag_ids?: string[]
          updated_at?: string
        }
        Update: {
          availability?: string
          category_ids?: string[]
          created_at?: string
          description?: Json
          gallery_ids?: string[]
          id?: string
          name?: string
          published_at?: string | null
          related_product_ids?: string[]
          scheduled_at?: string | null
          seo_description?: string | null
          seo_image?: string | null
          seo_title?: string | null
          slug?: string
          status?: string
          tag_ids?: string[]
          updated_at?: string
        }
        Relationships: []
      }
      profiles: {
        Row: {
          avatar_path: string | null
          bio: string | null
          created_at: string
          email: string
          id: string
          name: string
          updated_at: string
          website: string | null
        }
        Insert: {
          avatar_path?: string | null
          bio?: string | null
          created_at?: string
          email: string
          id: string
          name: string
          updated_at?: string
          website?: string | null
        }
        Update: {
          avatar_path?: string | null
          bio?: string | null
          created_at?: string
          email?: string
          id?: string
          name?: string
          updated_at?: string
          website?: string | null
        }
        Relationships: []
      }
      resources: {
        Row: {
          access: string
          body: Json
          category_ids: string[]
          created_at: string
          file_path: string | null
          id: string
          media_id: string | null
          published_at: string | null
          scheduled_at: string | null
          seo_description: string | null
          seo_image: string | null
          seo_title: string | null
          slug: string
          status: string
          summary: string | null
          tag_ids: string[]
          title: string
          type: string
          updated_at: string
        }
        Insert: {
          access?: string
          body?: Json
          category_ids?: string[]
          created_at?: string
          file_path?: string | null
          id: string
          media_id?: string | null
          published_at?: string | null
          scheduled_at?: string | null
          seo_description?: string | null
          seo_image?: string | null
          seo_title?: string | null
          slug: string
          status?: string
          summary?: string | null
          tag_ids?: string[]
          title: string
          type?: string
          updated_at?: string
        }
        Update: {
          access?: string
          body?: Json
          category_ids?: string[]
          created_at?: string
          file_path?: string | null
          id?: string
          media_id?: string | null
          published_at?: string | null
          scheduled_at?: string | null
          seo_description?: string | null
          seo_image?: string | null
          seo_title?: string | null
          slug?: string
          status?: string
          summary?: string | null
          tag_ids?: string[]
          title?: string
          type?: string
          updated_at?: string
        }
        Relationships: []
      }
      settings: {
        Row: {
          digest_frequency: string
          email_notifications: boolean
          locale: string
          product_updates: boolean
          theme: string
          updated_at: string
          user_id: string
        }
        Insert: {
          digest_frequency?: string
          email_notifications?: boolean
          locale?: string
          product_updates?: boolean
          theme?: string
          updated_at?: string
          user_id: string
        }
        Update: {
          digest_frequency?: string
          email_notifications?: boolean
          locale?: string
          product_updates?: boolean
          theme?: string
          updated_at?: string
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "settings_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: true
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      support_tickets: {
        Row: {
          category: string | null
          created_at: string
          id: string
          messages: Json
          priority: string
          state: string
          subject: string
          updated_at: string
          user_id: string
        }
        Insert: {
          category?: string | null
          created_at?: string
          id: string
          messages?: Json
          priority?: string
          state?: string
          subject: string
          updated_at?: string
          user_id: string
        }
        Update: {
          category?: string | null
          created_at?: string
          id?: string
          messages?: Json
          priority?: string
          state?: string
          subject?: string
          updated_at?: string
          user_id?: string
        }
        Relationships: []
      }
      surveys: {
        Row: {
          comments: string | null
          created_at: string
          id: string
          most_used: string | null
          satisfaction: number
          updated_at: string
          user_id: string
        }
        Insert: {
          comments?: string | null
          created_at?: string
          id: string
          most_used?: string | null
          satisfaction: number
          updated_at?: string
          user_id: string
        }
        Update: {
          comments?: string | null
          created_at?: string
          id?: string
          most_used?: string | null
          satisfaction?: number
          updated_at?: string
          user_id?: string
        }
        Relationships: []
      }
      tags: {
        Row: {
          created_at: string
          description: string | null
          id: string
          name: string
          slug: string
          updated_at: string
        }
        Insert: {
          created_at?: string
          description?: string | null
          id: string
          name: string
          slug: string
          updated_at?: string
        }
        Update: {
          created_at?: string
          description?: string | null
          id?: string
          name?: string
          slug?: string
          updated_at?: string
        }
        Relationships: []
      }
      team_members: {
        Row: {
          bio: string | null
          created_at: string
          id: string
          name: string
          portrait_id: string | null
          role: string
          social: Json | null
          sort_order: number
          updated_at: string
        }
        Insert: {
          bio?: string | null
          created_at?: string
          id: string
          name: string
          portrait_id?: string | null
          role: string
          social?: Json | null
          sort_order?: number
          updated_at?: string
        }
        Update: {
          bio?: string | null
          created_at?: string
          id?: string
          name?: string
          portrait_id?: string | null
          role?: string
          social?: Json | null
          sort_order?: number
          updated_at?: string
        }
        Relationships: []
      }
      testimonials: {
        Row: {
          attribution: string
          company: string | null
          created_at: string
          featured: boolean
          id: string
          quote: string
          updated_at: string
        }
        Insert: {
          attribution: string
          company?: string | null
          created_at?: string
          featured?: boolean
          id: string
          quote: string
          updated_at?: string
        }
        Update: {
          attribution?: string
          company?: string | null
          created_at?: string
          featured?: boolean
          id?: string
          quote?: string
          updated_at?: string
        }
        Relationships: []
      }
      user_roles: {
        Row: {
          id: string
          role: Database["public"]["Enums"]["app_role"]
          user_id: string
        }
        Insert: {
          id?: string
          role: Database["public"]["Enums"]["app_role"]
          user_id: string
        }
        Update: {
          id?: string
          role?: Database["public"]["Enums"]["app_role"]
          user_id?: string
        }
        Relationships: []
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      has_role: {
        Args: {
          _role: Database["public"]["Enums"]["app_role"]
          _user_id: string
        }
        Returns: boolean
      }
      place_order: {
        Args: { _address: Json; _email: string; _lines: Json; _name: string }
        Returns: Json
      }
      register_for_event: {
        Args: {
          _attendance: string
          _email: string
          _event_id: string
          _name: string
        }
        Returns: string
      }
    }
    Enums: {
      app_role: "admin" | "moderator" | "user"
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
}

type DatabaseWithoutInternals = Omit<Database, "__InternalSupabase">

type DefaultSchema = DatabaseWithoutInternals[Extract<keyof Database, "public">]

export type Tables<
  DefaultSchemaTableNameOrOptions extends
    | keyof (DefaultSchema["Tables"] & DefaultSchema["Views"])
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends (DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
        DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])
    : never) = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
      DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])[TableName] extends {
      Row: infer R
    }
    ? R
    : never
  : DefaultSchemaTableNameOrOptions extends keyof (DefaultSchema["Tables"] &
        DefaultSchema["Views"])
    ? (DefaultSchema["Tables"] &
        DefaultSchema["Views"])[DefaultSchemaTableNameOrOptions] extends {
        Row: infer R
      }
      ? R
      : never
    : never

export type TablesInsert<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends (DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never) = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Insert: infer I
    }
    ? I
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Insert: infer I
      }
      ? I
      : never
    : never

export type TablesUpdate<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends (DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never) = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Update: infer U
    }
    ? U
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Update: infer U
      }
      ? U
      : never
    : never

export type Enums<
  DefaultSchemaEnumNameOrOptions extends
    | keyof DefaultSchema["Enums"]
    | { schema: keyof DatabaseWithoutInternals },
  EnumName extends (DefaultSchemaEnumNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"]
    : never) = never,
> = DefaultSchemaEnumNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"][EnumName]
  : DefaultSchemaEnumNameOrOptions extends keyof DefaultSchema["Enums"]
    ? DefaultSchema["Enums"][DefaultSchemaEnumNameOrOptions]
    : never

export type CompositeTypes<
  PublicCompositeTypeNameOrOptions extends
    | keyof DefaultSchema["CompositeTypes"]
    | { schema: keyof DatabaseWithoutInternals },
  CompositeTypeName extends (PublicCompositeTypeNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"]
    : never) = never,
> = PublicCompositeTypeNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"][CompositeTypeName]
  : PublicCompositeTypeNameOrOptions extends keyof DefaultSchema["CompositeTypes"]
    ? DefaultSchema["CompositeTypes"][PublicCompositeTypeNameOrOptions]
    : never

export const Constants = {
  public: {
    Enums: {
      app_role: ["admin", "moderator", "user"],
    },
  },
} as const
